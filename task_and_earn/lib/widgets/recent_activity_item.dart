import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class RecentActivityItem extends StatelessWidget {
  final String type;
  final String title;
  final int amount;
  final String time;

  const RecentActivityItem({
    super.key,
    required this.type,
    required this.title,
    required this.amount,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getTypeIcon(),
              color: _getTypeColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$amount',
              style: AppTextStyles.caption.copyWith(
                color: _getTypeColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (type) {
      case 'task_completed':
        return AppColors.success;
      case 'referral_bonus':
        return AppColors.info;
      case 'daily_bonus':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case 'task_completed':
        return Icons.task_alt;
      case 'referral_bonus':
        return Icons.people;
      case 'daily_bonus':
        return Icons.card_giftcard;
      default:
        return Icons.star;
    }
  }
}
