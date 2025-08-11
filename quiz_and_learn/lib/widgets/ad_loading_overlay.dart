import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AdLoadingOverlay extends StatelessWidget {
  final String message;
  final bool showSpinner;
  final Color? backgroundColor;
  final Color? textColor;

  const AdLoadingOverlay({
    super.key,
    this.message = 'Loading Ad...',
    this.showSpinner = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner) ...[
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            message,
            style: AppTextStyles.body2.copyWith(
              color: textColor ?? Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AdLoadingPlaceholder extends StatelessWidget {
  final double height;
  final String message;
  final bool showSpinner;

  const AdLoadingPlaceholder({
    super.key,
    this.height = 50,
    this.message = 'Ad Loading...',
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Colors.grey[100],
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showSpinner) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              message,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdLoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String loadingText;
  final String normalText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AdLoadingButton({
    super.key,
    this.onPressed,
    required this.isLoading,
    this.loadingText = 'Loading...',
    required this.normalText,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon ?? Icons.play_arrow),
      label: Text(
        isLoading ? loadingText : normalText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
