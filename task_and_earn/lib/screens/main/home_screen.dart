import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _tasks = [];
  Map<String, dynamic>? _progress;
  Map<String, dynamic>? _walletBalance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tasksResponse = await _apiService.getTasks();
      final progressResponse = await _apiService.getTaskProgress();
      final walletResponse = await _apiService.getWalletBalance();

      if (mounted) {
        setState(() {
          _tasks = List<Map<String, dynamic>>.from(
            tasksResponse['success'] ? tasksResponse['data']['tasks'] : [],
          );
          _progress = progressResponse['success'] 
              ? progressResponse['data']['progress'] 
              : null;
          _walletBalance = walletResponse['success'] 
              ? walletResponse['data'] 
              : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.appName),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet Balance Card
                    _buildWalletCard(),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // Progress Card
                    _buildProgressCard(),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // Tasks Section
                    Text(
                      'Available Tasks',
                      style: AppTextStyles.headline2,
                    ),
                    const SizedBox(height: AppSizes.padding),
                    _buildTasksList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWalletCard() {
    final balance = _walletBalance?['balance'] ?? 0;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Text(
                  'Wallet Balance',
                  style: AppTextStyles.headline3,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              '$balance coins',
              style: AppTextStyles.headline1.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final totalEarnings = _progress?['totalEarnings'] ?? 0;
    final streak = _progress?['streak'] ?? 0;
    final dailyCompletions = _progress?['dailyCompletions'] ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppSizes.padding),
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    'Total Earnings',
                    '$totalEarnings coins',
                    Icons.monetization_on,
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    'Current Streak',
                    '$streak days',
                    Icons.local_fire_department,
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    'Today\'s Tasks',
                    '$dailyCompletions completed',
                    Icons.today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: AppSizes.paddingSmall),
        Text(
          value,
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          title,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    if (_tasks.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.padding),
          child: Center(
            child: Text('No tasks available at the moment.'),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.padding),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task['title'] ?? 'Untitled Task',
                    style: AppTextStyles.headline3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Text(
                    '${task['reward'] ?? 0} coins',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              task['description'] ?? 'No description available',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Row(
              children: [
                _buildTaskTag(task['type'] ?? 'unknown'),
                const SizedBox(width: AppSizes.paddingSmall),
                _buildTaskTag(task['category'] ?? 'general'),
                const SizedBox(width: AppSizes.paddingSmall),
                _buildTaskTag(task['difficulty'] ?? 'easy'),
              ],
            ),
            const SizedBox(height: AppSizes.padding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _completeTask(task),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: const Text('Complete Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        tag.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Future<void> _completeTask(Map<String, dynamic> task) async {
    try {
      final response = await _apiService.completeTask(
        taskId: task['id'],
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task completed! Earned ${response['data']['reward']} coins'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to complete task'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
} 