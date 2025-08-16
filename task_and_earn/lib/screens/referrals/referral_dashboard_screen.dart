import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/referral_stats_card.dart';
import '../../widgets/referral_user_item.dart';
import '../../models/referral_model.dart';

class ReferralDashboardScreen extends StatefulWidget {
  const ReferralDashboardScreen({super.key});

  @override
  State<ReferralDashboardScreen> createState() =>
      _ReferralDashboardScreenState();
}

class _ReferralDashboardScreenState extends State<ReferralDashboardScreen> {
  final List<ReferralModel> _referrals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReferrals();
  }

  Future<void> _loadReferrals() async {
    setState(() {
      _isLoading = true;
    });

    // Mock data - replace with API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _referrals.clear();
      _referrals.addAll([
        ReferralModel(
          id: '1',
          referredUser: 'John Doe',
          email: 'john@example.com',
          status: 'active',
          joinedAt: DateTime.now().subtract(const Duration(days: 5)),
          earnings: 100,
        ),
        ReferralModel(
          id: '2',
          referredUser: 'Jane Smith',
          email: 'jane@example.com',
          status: 'pending',
          joinedAt: DateTime.now().subtract(const Duration(days: 2)),
          earnings: 0,
        ),
        ReferralModel(
          id: '3',
          referredUser: 'Mike Johnson',
          email: 'mike@example.com',
          status: 'active',
          joinedAt: DateTime.now().subtract(const Duration(days: 10)),
          earnings: 150,
        ),
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userData;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.info,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.info,
                          AppColors.info.withOpacity(0.8)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.padding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Referral Program',
                              style: AppTextStyles.headline1.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacingMedium),
                            Text(
                              'Invite friends and earn together',
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.onPrimary.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Referral Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ReferralStatsCard(
                              title: 'Total Referrals',
                              value: user.referralCount.toString(),
                              icon: Icons.people,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingMedium),
                          Expanded(
                            child: ReferralStatsCard(
                              title: 'Active Referrals',
                              value: _referrals
                                  .where((r) => r.status == 'active')
                                  .length
                                  .toString(),
                              icon: Icons.check_circle,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingMedium),
                      Row(
                        children: [
                          Expanded(
                            child: ReferralStatsCard(
                              title: 'Total Earnings',
                              value: '${user.referralBonus}',
                              icon: Icons.monetization_on,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingMedium),
                          Expanded(
                            child: ReferralStatsCard(
                              title: 'This Month',
                              value: '75', // Mock data
                              icon: Icons.calendar_today,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Referral Link Section
              SliverToBoxAdapter(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: AppSizes.padding),
                  padding: const EdgeInsets.all(AppSizes.padding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Referral Link',
                        style: AppTextStyles.headline3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingMedium),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.padding),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSmall),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'https://taskearn.app/ref/${user.referralCode}',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textSecondary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Copy to clipboard
                              },
                              icon: const Icon(Icons.copy),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingMedium),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Share referral link
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSizes.padding),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radius),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingMedium),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to referral rewards
                              },
                              icon: const Icon(Icons.card_giftcard),
                              label: const Text('Rewards'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning,
                                foregroundColor: AppColors.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSizes.padding),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radius),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSizes.spacingLarge),
              ),

              // Referrals List Header
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.padding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Referrals',
                        style: AppTextStyles.headline3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to full referral history
                        },
                        child: Text(
                          'View All',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Referrals List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final referral = _referrals[index];
                    return ReferralUserItem(referral: referral);
                  },
                  childCount: _referrals.length,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSizes.spacingLarge),
              ),
            ],
          ),
        );
      },
    );
  }
}
