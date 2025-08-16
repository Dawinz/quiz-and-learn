import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/referral_model.dart';

class ReferralUserItem extends StatelessWidget {
  final ReferralModel referral;

  const ReferralUserItem({
    super.key,
    required this.referral,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.padding,
        vertical: AppSizes.spacingSmall,
      ),
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: referral.profilePicture != null
                ? Colors.transparent
                : AppColors.primary.withOpacity(0.1),
            backgroundImage: referral.profilePicture != null
                ? NetworkImage(referral.profilePicture!)
                : null,
            child: referral.profilePicture == null
                ? Text(
                    referral.referredUser.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: AppSizes.spacingMedium),

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral.referredUser,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSmall),
                Text(
                  referral.email,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSmall),
                Row(
                  children: [
                    Text(
                      referral.formattedJoinedDate,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: referral.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        referral.statusText,
                        style: AppTextStyles.caption.copyWith(
                          color: referral.statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Earnings
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${referral.earnings}',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              Text(
                'coins earned',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
