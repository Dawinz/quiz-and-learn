import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../services/api_service.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  State<WithdrawalHistoryScreen> createState() =>
      _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  List<Map<String, dynamic>> _withdrawals = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadWithdrawalHistory();
  }

  Future<void> _loadWithdrawalHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock data for now - would be API call in production
      _withdrawals = [
        {
          'id': '1',
          'amount': 100.0,
          'method': 'M-Pesa',
          'accountNumber': '0712345678',
          'status': 'pending',
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'adminFeedback': null,
        },
        {
          'id': '2',
          'amount': 50.0,
          'method': 'USDT',
          'accountNumber': '0x1234567890abcdef',
          'status': 'completed',
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'adminFeedback': 'Payment processed successfully',
        },
        {
          'id': '3',
          'amount': 200.0,
          'method': 'Airtel Money',
          'accountNumber': '0756789012',
          'status': 'declined',
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'adminFeedback': 'Invalid account number provided',
        },
        {
          'id': '4',
          'amount': 75.0,
          'method': 'Tigo Pesa',
          'accountNumber': '0745678901',
          'status': 'pending',
          'date': DateTime.now().subtract(const Duration(days: 4)),
          'adminFeedback': null,
        },
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading withdrawal history: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredWithdrawals {
    if (_selectedStatus == 'all') {
      return _withdrawals;
    }
    return _withdrawals.where((w) => w['status'] == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawal History'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWithdrawalHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(
                          value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(
                          value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(
                          value: 'declined', child: Text('Declined')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Withdrawals List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredWithdrawals.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: AppSizes.padding),
                            Text(
                              'No withdrawal history',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.padding),
                        itemCount: _filteredWithdrawals.length,
                        itemBuilder: (context, index) {
                          final withdrawal = _filteredWithdrawals[index];
                          return _WithdrawalHistoryCard(withdrawal: withdrawal);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawalHistoryCard extends StatelessWidget {
  final Map<String, dynamic> withdrawal;

  const _WithdrawalHistoryCard({required this.withdrawal});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${withdrawal['amount']} coins',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusChip(withdrawal['status']),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            '${withdrawal['method']} • ${withdrawal['accountNumber']}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'Requested on ${_formatDate(withdrawal['date'])}',
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[600],
            ),
          ),
          if (withdrawal['adminFeedback'] != null) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              decoration: BoxDecoration(
                color: _getFeedbackColor(withdrawal['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(
                  color:
                      _getFeedbackColor(withdrawal['status']).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFeedbackIcon(withdrawal['status']),
                    color: _getFeedbackColor(withdrawal['status']),
                    size: 16,
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Expanded(
                    child: Text(
                      withdrawal['adminFeedback'],
                      style: AppTextStyles.caption.copyWith(
                        color: _getFeedbackColor(withdrawal['status']),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        text = 'Pending';
        break;
      case 'completed':
        color = AppColors.success;
        text = 'Completed';
        break;
      case 'declined':
        color = AppColors.error;
        text = 'Declined';
        break;
      default:
        color = AppColors.info;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getFeedbackColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'declined':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _getFeedbackIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'declined':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
