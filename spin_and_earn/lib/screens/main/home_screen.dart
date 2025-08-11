import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../models/spin_reward_model.dart';
import '../../services/admob_service.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SpinWheelScreen(),
    const RewardsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Spin'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Rewards'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  bool _isSpinning = false;
  int _reward = 0;
  final AdMobService _adMobService = AdMobService();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    // Load ads on init
    _adMobService.loadRewardedAd();
    _adMobService.loadBannerAd();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _adMobService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.spinWheel),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.signOut();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.userData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authProvider.userData!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              children: [
                // Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Balance',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        '${user.coins} coins',
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.onPrimary,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLarge),

                // Spin Wheel
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _spinAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _spinAnimation.value * 20 * 3.14159,
                        child: CustomPaint(
                          size: const Size(300, 300),
                          painter: SpinWheelPainter(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLarge),

                // Spin Info
                Container(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${user.remainingSpins} ${AppStrings.remainingSpins}',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        '${AppStrings.dailyLimit}: ${user.dailyLimit}',
                        style: AppTextStyles.body2,
                      ),
                      if (!user.canSpin) ...[
                        const SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          'Come back tomorrow for more spins!',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLarge),

                // Spin Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: user.canSpin && !_isSpinning ? _spinWheel : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.paddingLarge,
                      ),
                    ),
                    child: _isSpinning
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            AppStrings.spin,
                            style: AppTextStyles.button.copyWith(fontSize: 20),
                          ),
                  ),
                ),
                const SizedBox(height: AppSizes.padding),

                // Watch Ad Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _adMobService.isRewardedAdReady
                        ? _showRewardedAd
                        : null,
                    icon: _adMobService.isRewardedAdLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_circle),
                    label: Text(
                      _adMobService.isRewardedAdLoading
                          ? 'Loading Ad...'
                          : AppStrings.watchAdForSpin,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.padding,
                      ),
                    ),
                  ),
                ),

                // Banner Ad at bottom
                const SizedBox(height: AppSizes.padding),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: _adMobService.createBannerAd(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _spinWheel() async {
    if (_isSpinning) return;

    try {
      // Call API to play spin
      final response = await _apiService.playSpin();

      if (response['success']) {
        final spinData = response['data'];
        _reward = spinData['prize']['coins'] ?? 0;

        setState(() {
          _isSpinning = true;
        });

        // Start spin animation
        _spinController.forward();

        // Wait for animation to complete
        await Future.delayed(const Duration(seconds: 3));

        // Show reward dialog
        if (mounted) {
          _showRewardDialog();
        }

        setState(() {
          _isSpinning = false;
        });

        // Reset animation
        _spinController.reset();

        // Refresh user data
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.updateUserProfile({});
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'Failed to spin'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.congratulations),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 64, color: AppColors.success),
            const SizedBox(height: AppSizes.padding),
            Text(
              '${AppStrings.youWon} $_reward ${AppStrings.coins}',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _processReward();
            },
            child: const Text('Claim'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRewardedAd() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final user = authProvider.userData!;
    // final firebaseService = FirebaseService();

    try {
      final rewardEarned = await _adMobService.showRewardedAd(
        onRewarded: () async {
          // User watched the ad, process via Cloud Function
          try {
            // await firebaseService.handleRewardedAdSpin(user.id);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You earned an extra spin!'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error processing reward: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
        onAdClosed: () {
          // Ad was closed without reward
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ad closed. Try again for an extra spin!'),
              ),
            );
          }
        },
        onAdFailedToShow: () {
          // Ad failed to show
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ad failed to load. Please try again.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          // Try to load another ad
          _adMobService.loadRewardedAd();
        },
      );

      if (!rewardEarned) {
        // Load another ad for next time
        _adMobService.loadRewardedAd();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error showing ad: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _processReward() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userData!;

    try {
      // Call the API to process the spin
      final response = await _apiService.playSpin();

      if (response['success']) {
        // Get the reward from the response
        final reward = response['data']['prize']['coins'] ?? 0;

        // Update user data
        await authProvider.updateUserProfile({});

        // Show success message using a different approach
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You earned $reward coins!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response['error']}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing reward: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class SpinWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw wheel segments
    for (int i = 0; i < 8; i++) {
      final paint = Paint()
        ..color = AppColors.wheelColors[i]
        ..style = PaintingStyle.fill;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, i * (3.14159 / 4), 3.14159 / 4, true, paint);
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 20, centerPaint);

    // Draw center icon
    final iconPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 15, iconPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards History'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.signOut();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.userData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authProvider.userData!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              children: [
                // Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Balance',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        '${user.coins} coins',
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.onPrimary,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLarge),

                // Recent Rewards
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.padding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Rewards',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: AppSizes.padding),
                      _buildRewardItem('Spin & Earn', 50, '2 hours ago'),
                      _buildRewardItem('Watch Ad', 25, '1 day ago'),
                      _buildRewardItem('Spin & Earn', 100, '2 days ago'),
                      _buildRewardItem('Daily Bonus', 75, '3 days ago'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLarge),

                // Statistics
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.padding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: AppSizes.padding),
                      _buildStatItem('Total Spins Today', '${user.dailyUsed}'),
                      _buildStatItem(
                          'Remaining Spins', '${user.remainingSpins}'),
                      _buildStatItem('Daily Limit', '${user.dailyLimit}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRewardItem(String source, int amount, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.monetization_on,
              color: AppColors.onPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source,
                  style:
                      AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  time,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            '+$amount',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.signOut();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.userData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authProvider.userData!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              children: [
                // Profile Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.padding),
                      Text(
                        user.name,
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        user.email,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLarge),

                // Settings Options
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'Manage push notifications',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.security,
                        title: 'Privacy',
                        subtitle: 'Privacy and security settings',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.help,
                        title: 'Help & Support',
                        subtitle: 'Get help and contact support',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.info,
                        title: 'About',
                        subtitle: 'App version and information',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body1),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
