import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class TaskDifficultyIndicator extends StatelessWidget {
  final String difficulty;

  const TaskDifficultyIndicator({
    super.key,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getDifficultyColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getDifficultyColor()),
      ),
      child: Text(
        difficulty,
        style: AppTextStyles.caption.copyWith(
          color: _getDifficultyColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
