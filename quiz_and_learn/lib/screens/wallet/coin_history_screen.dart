import 'package:flutter/material.dart';
import '../../models/coin_transaction.dart';
import '../../services/enhanced_wallet_service.dart';
import '../../constants/app_constants.dart';

class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  final EnhancedWalletService _walletService = EnhancedWalletService.instance;
  List<CoinTransaction> _transactions = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Wait for service to initialize
      await _walletService.initialize();

      // For now, create sample data
      await Future.delayed(const Duration(seconds: 1));

      _transactions = _getSampleTransactions();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading transactions: $e');
    }
  }

  List<CoinTransaction> _getSampleTransactions() {
    final now = DateTime.now();
    return [
      CoinTransaction(
        id: '1',
        userId: 'user1',
        type: TransactionType.dailyLogin,
        amount: 25,
        balanceAfter: 125,
        description: 'Daily login bonus (Day 3)',
        metadata: {'streak': 3, 'isConsecutive': true},
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      CoinTransaction(
        id: '2',
        userId: 'user1',
        type: TransactionType.quizCompletion,
        amount: 18,
        balanceAfter: 100,
        description: 'Quiz completion bonus: Science (Medium)',
        metadata: {
          'score': 8,
          'totalQuestions': 10,
          'category': 'Science',
          'difficulty': 'Medium'
        },
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
      CoinTransaction(
        id: '3',
        userId: 'user1',
        type: TransactionType.referral,
        amount: 100,
        balanceAfter: 82,
        description: 'Referral bonus for using code: ABC12345',
        metadata: {'referralCode': 'ABC12345', 'bonusType': 'code_usage'},
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      CoinTransaction(
        id: '4',
        userId: 'user1',
        type: TransactionType.achievement,
        amount: 50,
        balanceAfter: -18,
        description: 'Achievement unlocked: First Quiz',
        metadata: {
          'achievementId': 'first_quiz',
          'achievementTitle': 'First Quiz',
          'achievementTier': 'bronze'
        },
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      CoinTransaction(
        id: '5',
        userId: 'user1',
        type: TransactionType.premiumUnlock,
        amount: 200,
        balanceAfter: -68,
        description: 'Unlocked: Ad Removal (7 days)',
        metadata: {
          'featureId': 'ad_removal',
          'featureName': 'Ad Removal',
          'featureType': 'adRemoval',
          'duration': 7
        },
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      CoinTransaction(
        id: '6',
        userId: 'user1',
        type: TransactionType.quizCompletion,
        amount: 15,
        balanceAfter: 132,
        description: 'Quiz completion bonus: History (Easy)',
        metadata: {
          'score': 5,
          'totalQuestions': 10,
          'category': 'History',
          'difficulty': 'Easy'
        },
        timestamp: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  List<CoinTransaction> _getFilteredTransactions() {
    List<CoinTransaction> filtered = List.from(_transactions);

    // Filter by type
    if (_selectedFilter != 'all') {
      filtered = filtered
          .where((t) => t.type.toString().split('.').last == _selectedFilter)
          .toList();
    }

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((t) => t.category == _selectedCategory).toList();
    }

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filtered;
  }

  Map<String, dynamic> _getTransactionStats() {
    if (_transactions.isEmpty) {
      return {
        'totalEarned': 0,
        'totalSpent': 0,
        'netBalance': 0,
        'transactionCount': 0,
      };
    }

    int totalEarned = 0;
    int totalSpent = 0;

    for (final transaction in _transactions) {
      if (transaction.isPositive) {
        totalEarned += transaction.amount;
      } else {
        totalSpent += transaction.amount;
      }
    }

    return {
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'netBalance': totalEarned - totalSpent,
      'transactionCount': _transactions.length,
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (transactionDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _getFilteredTransactions();
    final stats = _getTransactionStats();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Coin History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Column(
              children: [
                // Statistics Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Balance Overview
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Earned',
                              '${stats['totalEarned']}',
                              Icons.trending_up,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Total Spent',
                              '${stats['totalSpent']}',
                              Icons.trending_down,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Net Balance',
                              '${stats['netBalance']}',
                              Icons.account_balance_wallet,
                              stats['netBalance'] >= 0
                                  ? Colors.blue
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Transactions',
                              '${stats['transactionCount']}',
                              Icons.receipt_long,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Filter Chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter by Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('all', 'All'),
                            _buildFilterChip('earned', 'Earned'),
                            _buildFilterChip('spent', 'Spent'),
                            _buildFilterChip('dailyLogin', 'Daily Login'),
                            _buildFilterChip('quizCompletion', 'Quiz'),
                            _buildFilterChip('referral', 'Referral'),
                            _buildFilterChip('achievement', 'Achievement'),
                            _buildFilterChip('premiumUnlock', 'Premium'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Filter by Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('all', 'All', isCategory: true),
                            _buildFilterChip('Earnings', 'Earnings',
                                isCategory: true),
                            _buildFilterChip('Spending', 'Spending',
                                isCategory: true),
                            _buildFilterChip('Refunds', 'Refunds',
                                isCategory: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Transactions List
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];
                            return _buildTransactionCard(transaction);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label,
      {bool isCategory = false}) {
    final isSelected =
        isCategory ? _selectedCategory == value : _selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (isCategory) {
              _selectedCategory = value;
            } else {
              _selectedFilter = value;
            }
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.onBackground,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.withOpacity(0.1),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(CoinTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Transaction Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: transaction.isPositive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  transaction.transactionIcon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(transaction.timestamp)} at ${_formatTime(transaction.timestamp)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (transaction.metadata.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatMetadata(transaction.metadata),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  transaction.formattedAmount,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: transaction.isPositive ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  'Balance: ${transaction.balanceAfter}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMetadata(Map<String, dynamic> metadata) {
    if (metadata.isEmpty) return '';

    final entries =
        metadata.entries.take(2).map((e) => '${e.key}: ${e.value}').join(', ');
    return entries;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or complete some activities to earn coins!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
