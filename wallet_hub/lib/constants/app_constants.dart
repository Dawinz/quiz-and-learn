import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFF03DAC6);
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
    color: AppColors.onSurface.withOpacity(0.7),
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
  static const String appName = 'Wallet Hub';
  static const String appTagline = 'Your 5-in-1 Earning Ecosystem';
  
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
  
  // Dashboard
  static const String balance = 'Balance';
  static const String coins = 'Coins';
  static const String withdraw = 'Withdraw';
  static const String transactions = 'Transactions';
  static const String goals = 'Goals';
  static const String settings = 'Settings';
  
  // Withdrawal
  static const String withdrawalRequest = 'Withdrawal Request';
  static const String selectMethod = 'Select Method';
  static const String enterAmount = 'Enter Amount';
  static const String enterAccount = 'Enter Account';
  static const String submitRequest = 'Submit Request';
  static const String minimumAmount = 'Minimum amount: 100 coins';
  
  // Goals
  static const String setGoals = 'Set Goals';
  static const String weeklyTarget = 'Weekly Target';
  static const String monthlyTarget = 'Monthly Target';
  static const String progress = 'Progress';
  static const String dailyTasks = 'Daily Tasks Needed';
  
  // Common
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String view = 'View';
  static const String close = 'Close';
}

class WithdrawalMethods {
  static const Map<String, String> methods = {
    'mpesa': 'M-Pesa',
    'tigopesa': 'Tigo Pesa',
    'airtel': 'Airtel Money',
    'halopesa': 'HaloPesa',
    'usdt': 'USDT (TRC20)',
  };
  
  static const Map<String, String> placeholders = {
    'mpesa': 'Enter M-Pesa phone number',
    'tigopesa': 'Enter Tigo Pesa phone number',
    'airtel': 'Enter Airtel Money phone number',
    'halopesa': 'Enter HaloPesa phone number',
    'usdt': 'Enter USDT wallet address',
  };
} 