import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../services/api_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _weeklyController = TextEditingController();
  final _monthlyController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _weeklyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.goals),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (_isEditing) {
                    _saveGoals(authProvider);
                  }
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.userData == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = authProvider.userData!;
          final goals = user.goals;
          final weeklyTarget = goals['weeklyTarget'] ?? 0;
          final monthlyTarget = goals['monthlyTarget'] ?? 0;
          final progress = goals['progress'] ?? 0;

          // Initialize controllers with current values
          if (!_isEditing) {
            _weeklyController.text = weeklyTarget.toString();
            _monthlyController.text = monthlyTarget.toString();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Progress
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
                        'Current Progress',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.padding),
                      Text(
                        '$progress coins',
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.onPrimary,
                          fontSize: 36,
                        ),
                      ),
                      Text(
                        'This week',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLarge),

                // Weekly Goal
                _GoalCard(
                  title: AppStrings.weeklyTarget,
                  target: weeklyTarget,
                  progress: progress,
                  controller: _weeklyController,
                  isEditing: _isEditing,
                ),
                const SizedBox(height: AppSizes.padding),

                // Monthly Goal
                _GoalCard(
                  title: AppStrings.monthlyTarget,
                  target: monthlyTarget,
                  progress: progress * 4, // Approximate monthly progress
                  controller: _monthlyController,
                  isEditing: _isEditing,
                ),
                const SizedBox(height: AppSizes.paddingLarge),

                // Daily Tasks Needed
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
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
                        AppStrings.dailyTasks,
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: AppSizes.padding),
                      _DailyTaskItem(
                        title: 'Complete surveys',
                        coins: 50,
                        completed: progress >= 50,
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      _DailyTaskItem(
                        title: 'Watch videos',
                        coins: 30,
                        completed: progress >= 80,
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      _DailyTaskItem(
                        title: 'Play games',
                        coins: 20,
                        completed: progress >= 100,
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

  Future<void> _saveGoals(AuthProvider authProvider) async {
    try {
      final weeklyTarget = int.tryParse(_weeklyController.text) ?? 0;
      final monthlyTarget = int.tryParse(_monthlyController.text) ?? 0;

      final apiService = ApiService();
      final response = await apiService.updateGoals(goals: {
        'weeklyTarget': weeklyTarget,
        'monthlyTarget': monthlyTarget,
        'progress': authProvider.userData?.goals['progress'] ?? 0,
      });

      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Goals updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        throw Exception(response['error']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating goals: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final int target;
  final int progress;
  final TextEditingController controller;
  final bool isEditing;

  const _GoalCard({
    required this.title,
    required this.target,
    required this.progress,
    required this.controller,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = target > 0 ? (progress / target * 100).clamp(0, 100) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
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
                title,
                style: AppTextStyles.heading3,
              ),
              if (isEditing)
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target',
                      isDense: true,
                    ),
                  ),
                )
              else
                Text(
                  '$target coins',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 100 ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$progress / $target coins',
                style: AppTextStyles.body2,
              ),
              Text(
                '${percentage.toInt()}%',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: percentage >= 100 ? AppColors.success : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyTaskItem extends StatelessWidget {
  final String title;
  final int coins;
  final bool completed;

  const _DailyTaskItem({
    required this.title,
    required this.coins,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? AppColors.success : Colors.grey,
          size: AppSizes.iconSizeSmall,
        ),
        const SizedBox(width: AppSizes.paddingSmall),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.body2.copyWith(
              decoration: completed ? TextDecoration.lineThrough : null,
              color: completed ? Colors.grey : AppColors.onSurface,
            ),
          ),
        ),
        Text(
          '+$coins coins',
          style: AppTextStyles.body2.copyWith(
            color: completed ? AppColors.success : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
} 