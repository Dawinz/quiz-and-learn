import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_item.dart';
import '../../models/transaction_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    // Mock data - replace with API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _transactions.clear();
      _transactions.addAll([
        TransactionModel(
          id: '1',
          type: 'task_completed',
          amount: 50,
          description: 'Math Quiz completed',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          status: 'completed',
        ),
        TransactionModel(
          id: '2',
          type: 'referral_bonus',
          amount: 100,
          description: 'New referral bonus',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          status: 'completed',
        ),
        TransactionModel(
          id: '3',
          type: 'withdrawal',
          amount: -200,
          description: 'Withdrawal to bank account',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          status: 'completed',
        ),
        TransactionModel(
          id: '4',
          type: 'task_completed',
          amount: 75,
          description: 'Science Quiz completed',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          status: 'completed',
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
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8)
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
                              'Wallet',
                              style: AppTextStyles.headline1.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacingMedium),
                            Text(
                              'Manage your earnings and transactions',
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

              // Balance Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: BalanceCard(
                              title: 'Current Balance',
                              amount: user.currentBalance,
                              icon: Icons.account_balance_wallet,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingMedium),
                          Expanded(
                            child: BalanceCard(
                              title: 'Total Earnings',
                              amount: user.totalEarnings,
                              icon: Icons.trending_up,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingMedium),
                      Row(
                        children: [
                          Expanded(
                            child: BalanceCard(
                              title: 'This Month',
                              amount: 450, // Mock data
                              icon: Icons.calendar_today,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingMedium),
                          Expanded(
                            child: BalanceCard(
                              title: 'Referral Bonus',
                              amount: user.referralBonus,
                              icon: Icons.people,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.padding),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to withdrawal screen
                          },
                          icon: const Icon(Icons.account_balance),
                          label: const Text('Withdraw'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
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
                            // Navigate to transaction history
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('History'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
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
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSizes.spacingLarge),
              ),

              // Recent Transactions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.padding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: AppTextStyles.headline3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to full transaction history
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

              // Transactions List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = _transactions[index];
                    return TransactionItem(transaction: transaction);
                  },
                  childCount: _transactions.length,
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
