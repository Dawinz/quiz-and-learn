import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactions),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return const Center(
              child: Text('Please log in to view transactions'),
            );
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: ApiService().getTransactions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final response = snapshot.data;
              if (response == null || !response['success']) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSizes.padding),
                      Text(
                        'Error: ${response?['error'] ?? 'Failed to load transactions'}',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.padding),
                      ElevatedButton(
                        onPressed: () {
                          // Retry loading transactions by rebuilding
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TransactionsScreen(),
                            ),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final transactions = response['data'] ?? [];

              if (transactions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: AppSizes.padding),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSizes.padding),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transactionData = transactions[index];
                  try {
                    return _TransactionCard(
                        transaction: TransactionModel.fromMap(transactionData,
                            transactionData['id']?.toString() ?? ''));
                  } catch (e) {
                    // Return a placeholder card if there's an error
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.padding),
                      padding: const EdgeInsets.all(AppSizes.padding),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: const Text(
                        'Error loading transaction',
                        style: TextStyle(color: AppColors.error),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.padding),
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
      child: Row(
        children: [
          // Transaction Icon
          Container(
            padding: const EdgeInsets.all(AppSizes.padding),
            decoration: BoxDecoration(
              color: _getTransactionColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: Icon(
              _getTransactionIcon(),
              color: _getTransactionColor(),
              size: AppSizes.iconSize,
            ),
          ),
          const SizedBox(width: AppSizes.padding),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTitle(),
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(transaction.date),
                  style: AppTextStyles.caption,
                ),
                if (transaction.description != null) ...[
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    transaction.description!,
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.type == TransactionType.earn ? '+' : '-'}${transaction.amount}',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getTransactionColor(),
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  transaction.status.toString().split('.').last.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor() {
    switch (transaction.type) {
      case TransactionType.earn:
        return AppColors.success;
      case TransactionType.spend:
        return AppColors.warning;
      case TransactionType.withdrawal:
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case TransactionType.earn:
        return Icons.add_circle;
      case TransactionType.spend:
        return Icons.remove_circle;
      case TransactionType.withdrawal:
        return Icons.money_off;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _getTransactionTitle() {
    switch (transaction.type) {
      case TransactionType.earn:
        return 'Earning';
      case TransactionType.spend:
        return 'Spending';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      default:
        return 'Transaction';
    }
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case TransactionStatus.pending:
        return AppColors.warning;
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.failed:
        return AppColors.error;
      case TransactionStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}
