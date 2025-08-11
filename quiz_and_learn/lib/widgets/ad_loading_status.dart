import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/admob_service.dart';

class AdLoadingStatus extends StatelessWidget {
  final bool showDetails;
  final bool showSpinner;
  final String? customMessage;
  final VoidCallback? onRetry;

  const AdLoadingStatus({
    super.key,
    this.showDetails = false,
    this.showSpinner = true,
    this.customMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, bool>>(
      stream: _getAdLoadingStream(),
      builder: (context, snapshot) {
        final adMobService = AdMobService.instance;
        final isLoading = adMobService.areAdsLoading;
        final loadingStatus = adMobService.adLoadingStatus;
        final loadingProgress = adMobService.adLoadingProgress;

        if (!isLoading) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (showSpinner) ...[
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      customMessage ?? 'Loading Ads...',
                      style: AppTextStyles.body1.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (onRetry != null) ...[
                    IconButton(
                      onPressed: onRetry,
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      tooltip: 'Retry',
                    ),
                  ],
                ],
              ),
              if (showDetails && loadingProgress.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...loadingProgress.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.blue[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        );
      },
    );
  }

  Stream<Map<String, bool>> _getAdLoadingStream() async* {
    final adMobService = AdMobService.instance;
    while (true) {
      yield adMobService.adLoadingStatus;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}

class AdStatusIndicator extends StatelessWidget {
  final String adType;
  final bool isLoading;
  final bool isAvailable;
  final VoidCallback? onTap;

  const AdStatusIndicator({
    super.key,
    required this.adType,
    required this.isLoading,
    required this.isAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isLoading) {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
      statusText = 'Loading';
    } else if (isAvailable) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Ready';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = 'Failed';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              statusIcon,
              size: 16,
              color: statusColor,
            ),
            const SizedBox(width: 4),
            Text(
              '$adType: $statusText',
              style: AppTextStyles.caption.copyWith(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdLoadingProgressBar extends StatelessWidget {
  final String adType;
  final bool isLoading;
  final double? progress;

  const AdLoadingProgressBar({
    super.key,
    required this.adType,
    required this.isLoading,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Loading $adType Ad...',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
