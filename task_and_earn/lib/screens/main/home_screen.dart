import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/recent_activity_item.dart';
import '../tasks/task_list_screen.dart';
import '../wallet/wallet_screen.dart';
import '../referrals/referral_dashboard_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0
          ? const PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: AppBarWidget(),
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const DashboardTab();
      case 1:
        return const TaskListScreen();
      case 2:
        return const WalletScreen();
      case 3:
        return const ReferralDashboardScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const DashboardTab();
    }
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = authProvider.userData;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.padding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user.name}!',
                      style: AppTextStyles.headline2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      'Ready to earn some coins today?',
                      style: AppTextStyles.body1.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingLarge),

              // Stats Section
              Text(
                'Your Stats',
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSizes.spacingMedium,
                mainAxisSpacing: AppSizes.spacingMedium,
                childAspectRatio: 1.5,
                children: [
                  StatsCard(
                    title: 'Total Earnings',
                    value: '${user.totalEarnings}',
                    icon: Icons.monetization_on,
                    color: AppColors.success,
                  ),
                  StatsCard(
                    title: 'Tasks Completed',
                    value: '${user.tasksCompleted}',
                    icon: Icons.task_alt,
                    color: AppColors.primary,
                  ),
                  StatsCard(
                    title: 'Current Balance',
                    value: '${user.currentBalance}',
                    icon: Icons.account_balance_wallet,
                    color: AppColors.warning,
                  ),
                  StatsCard(
                    title: 'Referral Bonus',
                    value: '${user.referralBonus}',
                    icon: Icons.people,
                    color: AppColors.info,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLarge),

              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.task_alt,
                      label: 'Browse Tasks',
                      onTap: () {
                        // Navigate to tasks
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingMedium),
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.account_balance_wallet,
                      label: 'View Wallet',
                      onTap: () {
                        // Navigate to wallet
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLarge),

              // Recent Activity
              Text(
                'Recent Activity',
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              _buildRecentActivityList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    // Mock data - replace with real data from API
    final activities = [
      {
        'type': 'task_completed',
        'title': 'Math Quiz',
        'amount': 50,
        'time': '2 hours ago'
      },
      {
        'type': 'referral_bonus',
        'title': 'New Referral',
        'amount': 100,
        'time': '1 day ago'
      },
      {
        'type': 'task_completed',
        'title': 'Science Quiz',
        'amount': 75,
        'time': '2 days ago'
      },
    ];

    return Column(
      children: activities.map((activity) {
        return RecentActivityItem(
          type: activity['type'] as String,
          title: activity['title'] as String,
          amount: activity['amount'] as int,
          time: activity['time'] as String,
        );
      }).toList(),
    );
  }
}
