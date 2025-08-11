import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../constants/app_constants.dart';
import 'withdrawal_screen.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  bool _isRefreshing = false;
  Map<String, dynamic>? _earningsSummary;
  List<Map<String, dynamic>> _pendingWithdrawals = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.wait([
        _loadEarningsSummary(),
        _loadPendingWithdrawals(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _loadEarningsSummary() async {
    try {
      // Mock data for now - would be API call in production
      _earningsSummary = {
        'weeklyEarnings': 150.0,
        'monthlyEarnings': 650.0,
        'totalEarnings': 1250.0,
        'pendingWithdrawals': 200.0,
      };
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadPendingWithdrawals() async {
    try {
      // Mock data for now - would be API call in production
      _pendingWithdrawals = [
        {
          'id': '1',
          'amount': 100.0,
          'method': 'M-Pesa',
          'status': 'pending',
          'date': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': '2',
          'amount': 50.0,
          'method': 'USDT',
          'status': 'pending',
          'date': DateTime.now().subtract(const Duration(days: 2)),
        },
      ];
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: Icon(_isRefreshing ? Icons.refresh : Icons.refresh_outlined),
            onPressed: _isRefreshing ? null : _loadDashboardData,
          ),
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
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.userData == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = authProvider.userData!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Message
                  Text(
                    'Welcome back, ${user.name}!',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: AppSizes.padding),

                  // Balance Card
                  _BalanceCard(balance: user.coins),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // Earnings Summary
                  if (_earningsSummary != null) ...[
                    _EarningsSummaryCard(summary: _earningsSummary!),
                    const SizedBox(height: AppSizes.paddingLarge),
                  ],

                  // Quick Actions
                  Text('Quick Actions', style: AppTextStyles.heading3),
                  const SizedBox(height: AppSizes.padding),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.money_off,
                          title: AppStrings.withdraw,
                          color: AppColors.warning,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WithdrawalScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.padding),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.receipt_long,
                          title: AppStrings.transactions,
                          color: AppColors.info,
                          onTap: () {
                            // Switch to transactions tab
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.padding),

                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.flag,
                          title: AppStrings.goals,
                          color: AppColors.success,
                          onTap: () {
                            // Navigate to goals screen
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.padding),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.settings,
                          title: AppStrings.settings,
                          color: AppColors.primary,
                          onTap: () {
                            // Navigate to settings screen
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // Pending Withdrawals
                  if (_pendingWithdrawals.isNotEmpty) ...[
                    Text('Pending Withdrawals', style: AppTextStyles.heading3),
                    const SizedBox(height: AppSizes.padding),
                    _PendingWithdrawalsCard(withdrawals: _pendingWithdrawals),
                    const SizedBox(height: AppSizes.paddingLarge),
                  ],

                  // Recent Activity
                  Text('Recent Activity', style: AppTextStyles.heading3),
                  const SizedBox(height: AppSizes.padding),

                  // Placeholder for recent transactions
                  Container(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'No recent activity',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.onPrimary,
                    size: AppSizes.iconSizeLarge,
                  ),
                  const SizedBox(width: AppSizes.padding),
                  Text(
                    AppStrings.balance,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Text(
            '$balance',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.onPrimary,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            AppStrings.coins,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;

  const _EarningsSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Summary',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  title: 'This Week',
                  value: '${summary['weeklyEarnings']}',
                  icon: Icons.trending_up,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSizes.padding),
              Expanded(
                child: _SummaryItem(
                  title: 'This Month',
                  value: '${summary['monthlyEarnings']}',
                  icon: Icons.calendar_today,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  title: 'Total Earnings',
                  value: '${summary['totalEarnings']}',
                  icon: Icons.account_balance_wallet,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.padding),
              Expanded(
                child: _SummaryItem(
                  title: 'Pending',
                  value: '${summary['pendingWithdrawals']}',
                  icon: Icons.pending,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PendingWithdrawalsCard extends StatelessWidget {
  final List<Map<String, dynamic>> withdrawals;

  const _PendingWithdrawalsCard({required this.withdrawals});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Withdrawals',
                style: AppTextStyles.heading3,
              ),
              Text(
                '${withdrawals.length}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          ...withdrawals.map((withdrawal) => _WithdrawalItem(
                amount: withdrawal['amount'],
                method: withdrawal['method'],
                date: withdrawal['date'],
              )),
        ],
      ),
    );
  }
}

class _WithdrawalItem extends StatelessWidget {
  final double amount;
  final String method;
  final DateTime date;

  const _WithdrawalItem({
    required this.amount,
    required this.method,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: const Icon(
              Icons.pending,
              color: AppColors.onPrimary,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$amount coins',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$method • ${_formatDate(date)}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(
                color: AppColors.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '$difference days ago';
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.padding),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Icon(icon, color: color, size: AppSizes.iconSizeLarge),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              title,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
