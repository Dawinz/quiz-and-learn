import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE91E63);
  static const Color secondary = Color(0xFFFF9800);
  static const Color accent = Color(0xFF9C27B0);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Spin wheel colors
  static const List<Color> wheelColors = [
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF00BCD4), // Cyan
    Color(0xFF795548), // Brown
  ];
}

class AppTextStyles {
  static TextStyle get heading1 => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      );

  static TextStyle get heading2 => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get heading3 => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get body1 => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.onSurface,
      );

  static TextStyle get body2 => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.onSurface,
      );

  static TextStyle get caption => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.onSurface.withValues(alpha: 0.7),
      );

  static TextStyle get button => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onPrimary,
      );
}

class AppSizes {
  static const double padding = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingLarge = 24.0;
  static const double radius = 12.0;
  static const double radiusSmall = 8.0;
  static const double radiusLarge = 16.0;
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeLarge = 32.0;
}

class AppStrings {
  static const String appName = 'Spin & Earn';
  static const String appTagline = 'Spin the wheel, earn coins!';

  // Authentication
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';

  // Spin Wheel
  static const String spin = 'SPIN!';
  static const String spinWheel = 'Spin Wheel';
  static const String remainingSpins = 'Remaining Spins';
  static const String dailyLimit = 'Daily Limit';
  static const String nextSpinIn = 'Next free spin in';
  static const String watchAdForSpin = 'Watch Ad for Extra Spin';
  static const String congratulations = 'Congratulations!';
  static const String youWon = 'You won';
  static const String coins = 'coins!';

  // Rewards
  static const String rewardsHistory = 'Rewards History';
  static const String noRewardsYet = 'No rewards yet';
  static const String spinToEarn = 'Spin to earn your first coins!';

  // Settings
  static const String settings = 'Settings';
  static const String profile = 'Profile';
  static const String balance = 'Balance';

  // Common
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String close = 'Close';
}

class SpinWheelConfig {
  static const int dailySpinLimit = 5;
  static const List<int> rewardAmounts = [5, 10, 20, 50, 100];
  static const List<double> rewardProbabilities = [
    0.4,
    0.3,
    0.2,
    0.08,
    0.02
  ]; // 40%, 30%, 20%, 8%, 2%

  static int getRandomReward() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    double cumulative = 0;

    for (int i = 0; i < rewardProbabilities.length; i++) {
      cumulative += rewardProbabilities[i] * 100;
      if (random < cumulative) {
        return rewardAmounts[i];
      }
    }

    return rewardAmounts[0]; // Default to lowest reward
  }
}

class AdMobConfig {
  // Test Ad Unit IDs - Replace with your actual ad unit IDs
  static const String androidRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String iosRewardedAdUnitId =
      'ca-app-pub-3940256099942544/1712485313';

  static String getRewardedAdUnitId(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.android) {
      return androidRewardedAdUnitId;
    } else {
      return iosRewardedAdUnitId;
    }
  }
}
