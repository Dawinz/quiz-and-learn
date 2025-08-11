import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../providers/auth_provider.dart";
import "../../services/admob_service.dart";
import "../../services/wallet_service.dart";
import "../../constants/app_constants.dart";
import "../quiz/quiz_category_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final walletService = Provider.of<WalletService>(context);
    final user = authProvider.userData;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.appName),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                children: [
                  // Welcome Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.padding),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  user?.name.substring(0, 1).toUpperCase() ??
                                      "U",
                                  style: AppTextStyles.headline2.copyWith(
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome back, ${user?.name ?? 'User'}!",
                                      style: AppTextStyles.headline3,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.email ?? "",
                                      style: AppTextStyles.body2.copyWith(
                                        color: AppColors.onBackground
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                "Coins",
                                "${walletService.coins}",
                                Icons.monetization_on,
                                AppColors.success,
                              ),
                              _buildStatCard(
                                "Referrals",
                                "${user?.referralCount ?? 0}",
                                Icons.people,
                                AppColors.info,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Watch Ad Button
                          _buildWatchAdButton(walletService),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Features Section
                  Text(
                    "Available Features",
                    style: AppTextStyles.headline2,
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 350, // Reduced height to prevent overflow
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          0.85, // Reduced aspect ratio to fit content
                      children: [
                        _buildFeatureCard(
                          "Take Quizzes",
                          "Test your knowledge and earn coins",
                          Icons.quiz,
                          AppColors.primary,
                          () => _navigateToQuiz(),
                        ),
                        _buildFeatureCard(
                          "Earn Coins",
                          "Complete tasks and earn rewards",
                          Icons.monetization_on,
                          AppColors.success,
                          () => _showComingSoonDialog("Coins Feature"),
                        ),
                        _buildFeatureCard(
                          "Refer Friends",
                          "Invite friends and earn bonuses",
                          Icons.people,
                          AppColors.info,
                          () => _showComingSoonDialog("Referral Feature"),
                        ),
                        _buildFeatureCard(
                          "Track Progress",
                          "Monitor your learning journey",
                          Icons.trending_up,
                          AppColors.warning,
                          () => _showComingSoonDialog("Progress Tracking"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: 32), // Add bottom padding to prevent overflow
                ],
              ),
            ),
          ),
          // Banner Ad at bottom
          _buildBannerAd(),
        ],
      ),
    );
  }

  Widget _buildWatchAdButton(WalletService walletService) {
    return Consumer<WalletService>(
      builder: (context, wallet, child) {
        final canWatchAd = wallet.canReceiveReward;
        final timeUntilNext = wallet.timeUntilNextReward;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canWatchAd ? _showRewardedAd : null,
            icon: Icon(canWatchAd ? Icons.play_circle : Icons.timer),
            label: Text(
              canWatchAd
                  ? "Watch Ad & Earn +10 Coins"
                  : "Next ad in ${timeUntilNext?.inSeconds ?? 0}s",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: canWatchAd
                  ? AppColors.success
                  : AppColors.onBackground.withOpacity(0.3),
              foregroundColor: canWatchAd
                  ? Colors.white
                  : AppColors.onBackground.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBannerAd() {
    final adMobService = AdMobService.instance;
    final bannerAd = adMobService.getBottomBannerAd();

    if (bannerAd == null) {
      return const SizedBox(height: 50); // Placeholder height
    }

    return Container(
      width: double.infinity,
      height: 50,
      child: bannerAd,
    );
  }

  void _showRewardedAd() async {
    final adMobService = AdMobService.instance;

    try {
      final success = await adMobService.showRewardedAdForCoins();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Congratulations! You earned +10 coins!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to show ad. Please try again.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headline3.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color), // Reduced icon size
              const SizedBox(height: 12), // Reduced spacing
              Text(
                title,
                style: AppTextStyles.headline3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6), // Reduced spacing
              Text(
                description,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.onBackground.withOpacity(0.7),
                  fontSize: 12, // Reduced font size
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Limit to 2 lines
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QuizCategoryScreen(),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$feature Coming Soon!"),
        content: Text(
          "This feature is currently under development and will be available in a future update.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
