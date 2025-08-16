import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coin_transaction.dart';
import '../models/referral_model.dart';
import '../models/premium_feature.dart';
import '../models/quiz_achievement.dart';

class EnhancedWalletService extends ChangeNotifier {
  static EnhancedWalletService? _instance;
  static EnhancedWalletService get instance =>
      _instance ??= EnhancedWalletService._();

  EnhancedWalletService._();

  // Storage keys
  static const String _coinsKey = 'user_coins';
  static const String _lastRewardTimeKey = 'last_reward_time';
  static const String _lastDailyLoginKey = 'last_daily_login';
  static const String _dailyLoginStreakKey = 'daily_login_streak';
  static const String _referralCodeKey = 'user_referral_code';
  static const String _usedReferralCodeKey = 'used_referral_code';
  static const String _transactionsKey = 'coin_transactions';
  static const String _premiumFeaturesKey = 'user_premium_features';

  // Coin balance and state
  int _coins = 0;
  DateTime? _lastRewardTime;
  DateTime? _lastDailyLogin;
  int _dailyLoginStreak = 0;
  String? _referralCode;
  String? _usedReferralCode;
  bool _isInitialized = false;

  // Lists
  List<CoinTransaction> _transactions = [];
  List<UserPremiumFeature> _premiumFeatures = [];

  // Getters
  int get coins => _coins;
  DateTime? get lastRewardTime => _lastRewardTime;
  DateTime? get lastDailyLogin => _lastDailyLogin;
  int get dailyLoginStreak => _dailyLoginStreak;
  String? get referralCode => _referralCode;
  String? get usedReferralCode => _usedReferralCode;
  bool get isInitialized => _isInitialized;
  List<CoinTransaction> get transactions => List.unmodifiable(_transactions);
  List<UserPremiumFeature> get premiumFeatures =>
      List.unmodifiable(_premiumFeatures);

  /// Initialize the enhanced wallet service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load basic wallet data
      _coins = prefs.getInt(_coinsKey) ?? 0;

      final lastRewardTimestamp = prefs.getInt(_lastRewardTimeKey);
      if (lastRewardTimestamp != null) {
        _lastRewardTime =
            DateTime.fromMillisecondsSinceEpoch(lastRewardTimestamp);
      }

      final lastDailyLoginTimestamp = prefs.getInt(_lastDailyLoginKey);
      if (lastDailyLoginTimestamp != null) {
        _lastDailyLogin =
            DateTime.fromMillisecondsSinceEpoch(lastDailyLoginTimestamp);
      }

      _dailyLoginStreak = prefs.getInt(_dailyLoginStreakKey) ?? 0;
      _referralCode = prefs.getString(_referralCodeKey);
      _usedReferralCode = prefs.getString(_usedReferralCodeKey);

      // Load transactions
      await _loadTransactions();

      // Load premium features
      await _loadPremiumFeatures();

      // Generate referral code if not exists
      if (_referralCode == null) {
        _referralCode = _generateReferralCode();
        await prefs.setString(_referralCodeKey, _referralCode!);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing enhanced wallet service: $e');
      _isInitialized = true;
    }
  }

  /// Add coins to wallet with transaction tracking
  Future<bool> addCoins(
    int amount, {
    required TransactionType type,
    String description = '',
    Map<String, dynamic> metadata = const {},
    String? referenceId,
  }) async {
    if (amount <= 0) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final oldBalance = _coins;
      _coins += amount;

      // Save new balance
      await prefs.setInt(_coinsKey, _coins);

      // Create and save transaction
      final transaction = CoinTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // TODO: Replace with actual user ID
        type: type,
        amount: amount,
        balanceAfter: _coins,
        description: description,
        metadata: metadata,
        timestamp: DateTime.now(),
        referenceId: referenceId,
      );

      _transactions.add(transaction);
      await _saveTransactions();

      debugPrint(
          'Added $amount coins from ${type.toString().split('.').last}. New balance: $_coins');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding coins: $e');
      return false;
    }
  }

  /// Remove coins from wallet with transaction tracking
  Future<bool> removeCoins(
    int amount, {
    required TransactionType type,
    String description = '',
    Map<String, dynamic> metadata = const {},
    String? referenceId,
  }) async {
    if (amount <= 0 || _coins < amount) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final oldBalance = _coins;
      _coins -= amount;

      // Save new balance
      await prefs.setInt(_coinsKey, _coins);

      // Create and save transaction
      final transaction = CoinTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // TODO: Replace with actual user ID
        timestamp: DateTime.now(),
        type: type,
        amount: amount,
        balanceAfter: _coins,
        description: description,
        metadata: metadata,
        referenceId: referenceId,
      );

      _transactions.add(transaction);
      await _saveTransactions();

      debugPrint(
          'Removed $amount coins for ${type.toString().split('.').last}. New balance: $_coins');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error removing coins: $e');
      return false;
    }
  }

  /// Daily login bonus system
  Future<bool> claimDailyLoginBonus() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Check if already claimed today
      if (_lastDailyLogin != null) {
        final lastLogin = DateTime(_lastDailyLogin!.year,
            _lastDailyLogin!.month, _lastDailyLogin!.day);
        if (lastLogin.isAtSameMomentAs(today)) {
          return false; // Already claimed today
        }
      }

      // Check if it's consecutive day
      bool isConsecutive = false;
      if (_lastDailyLogin != null) {
        final lastLogin = DateTime(_lastDailyLogin!.year,
            _lastDailyLogin!.month, _lastDailyLogin!.day);
        final yesterday = today.subtract(const Duration(days: 1));
        isConsecutive = lastLogin.isAtSameMomentAs(yesterday);
      }

      // Calculate bonus based on streak
      int bonusAmount = _calculateDailyLoginBonus();

      // Add coins
      final success = await addCoins(
        bonusAmount,
        type: TransactionType.dailyLogin,
        description: 'Daily login bonus (Day ${_dailyLoginStreak + 1})',
        metadata: {
          'streak': _dailyLoginStreak + 1,
          'isConsecutive': isConsecutive,
        },
      );

      if (success) {
        // Update streak and last login
        if (isConsecutive) {
          _dailyLoginStreak++;
        } else {
          _dailyLoginStreak = 1;
        }

        _lastDailyLogin = now;

        // Save to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_lastDailyLoginKey, now.millisecondsSinceEpoch);
        await prefs.setInt(_dailyLoginStreakKey, _dailyLoginStreak);

        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint('Error claiming daily login bonus: $e');
      return false;
    }
  }

  /// Calculate daily login bonus based on streak
  int _calculateDailyLoginBonus() {
    // Base bonus: 10 coins
    // Streak bonus: +5 coins per day, max 50 coins
    final streakBonus = min(_dailyLoginStreak * 5, 50);
    return 10 + streakBonus;
  }

  /// Check if daily login bonus is available
  bool get canClaimDailyLoginBonus {
    if (_lastDailyLogin == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = DateTime(
        _lastDailyLogin!.year, _lastDailyLogin!.month, _lastDailyLogin!.day);

    return !lastLogin.isAtSameMomentAs(today);
  }

  /// Get time until next daily login bonus
  Duration? get timeUntilNextDailyLogin {
    if (_lastDailyLogin == null) return Duration.zero;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = DateTime(
        _lastDailyLogin!.year, _lastDailyLogin!.month, _lastDailyLogin!.day);

    if (lastLogin.isAtSameMomentAs(today)) {
      final tomorrow = today.add(const Duration(days: 1));
      return tomorrow.difference(now);
    }

    return Duration.zero;
  }

  /// Referral system
  Future<bool> useReferralCode(String code) async {
    try {
      if (_usedReferralCode != null) {
        return false; // Already used a referral code
      }

      // TODO: Validate referral code with backend
      // For now, simulate validation
      if (code.length < 6) return false;

      // Add referral bonus
      const referralBonus = 100; // 100 coins for using referral code
      final success = await addCoins(
        referralBonus,
        type: TransactionType.referral,
        description: 'Referral bonus for using code: $code',
        metadata: {
          'referralCode': code,
          'bonusType': 'code_usage',
        },
      );

      if (success) {
        _usedReferralCode = code;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_usedReferralCodeKey, code);
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint('Error using referral code: $e');
      return false;
    }
  }

  /// Get referral bonus for referring someone
  Future<bool> giveReferralBonus(String referredUserId) async {
    try {
      const referralBonus = 50; // 50 coins for referring someone
      final success = await addCoins(
        referralBonus,
        type: TransactionType.referral,
        description: 'Referral bonus for inviting a friend',
        metadata: {
          'referredUserId': referredUserId,
          'bonusType': 'referral_invite',
        },
        referenceId: referredUserId,
      );

      return success;
    } catch (e) {
      debugPrint('Error giving referral bonus: $e');
      return false;
    }
  }

  /// Achievement bonus system
  Future<bool> giveAchievementBonus(QuizAchievement achievement) async {
    try {
      final success = await addCoins(
        achievement.pointsReward,
        type: TransactionType.achievement,
        description: 'Achievement unlocked: ${achievement.title}',
        metadata: {
          'achievementId': achievement.id,
          'achievementTitle': achievement.title,
          'achievementTier': achievement.tier.toString().split('.').last,
          'pointsReward': achievement.pointsReward,
        },
        referenceId: achievement.id,
      );

      return success;
    } catch (e) {
      debugPrint('Error giving achievement bonus: $e');
      return false;
    }
  }

  /// Quiz completion bonus
  Future<bool> giveQuizCompletionBonus({
    required int score,
    required int totalQuestions,
    required String category,
    required String difficulty,
  }) async {
    try {
      // Base bonus: 10 coins
      // Score bonus: +1 coin per correct answer
      // Difficulty bonus: Easy +0, Medium +5, Hard +10
      int difficultyBonus = 0;
      switch (difficulty.toLowerCase()) {
        case 'medium':
          difficultyBonus = 5;
          break;
        case 'hard':
          difficultyBonus = 10;
          break;
      }

      final bonusAmount = 10 + score + difficultyBonus;

      final success = await addCoins(
        bonusAmount,
        type: TransactionType.quizCompletion,
        description: 'Quiz completion bonus: $category ($difficulty)',
        metadata: {
          'score': score,
          'totalQuestions': totalQuestions,
          'category': category,
          'difficulty': difficulty,
          'difficultyBonus': difficultyBonus,
        },
      );

      return success;
    } catch (e) {
      debugPrint('Error giving quiz completion bonus: $e');
      return false;
    }
  }

  /// Premium features management
  Future<bool> unlockPremiumFeature(PremiumFeature feature) async {
    try {
      if (_coins < feature.coinCost) return false;

      // Remove coins
      final success = await removeCoins(
        feature.coinCost,
        type: TransactionType.premiumUnlock,
        description: 'Unlocked: ${feature.name}',
        metadata: {
          'featureId': feature.id,
          'featureName': feature.name,
          'featureType': feature.type.toString().split('.').last,
          'duration': feature.duration?.inDays,
        },
        referenceId: feature.id,
      );

      if (success) {
        // Add premium feature
        final userFeature = UserPremiumFeature(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user', // TODO: Replace with actual user ID
          featureId: feature.id,
          status: FeatureStatus.unlocked,
          unlockedAt: DateTime.now(),
          expiresAt: feature.duration != null
              ? DateTime.now().add(feature.duration!)
              : null,
          coinCost: feature.coinCost,
        );

        _premiumFeatures.add(userFeature);
        await _savePremiumFeatures();
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint('Error unlocking premium feature: $e');
      return false;
    }
  }

  /// Check if premium feature is active
  bool isPremiumFeatureActive(String featureId) {
    final feature = _premiumFeatures.firstWhere(
      (f) => f.featureId == featureId,
      orElse: () => UserPremiumFeature(
        id: '',
        userId: '',
        featureId: featureId,
        status: FeatureStatus.locked,
        unlockedAt: DateTime.now(),
        coinCost: 0,
      ),
    );

    return feature.isActive;
  }

  /// Get active premium features
  List<UserPremiumFeature> get activePremiumFeatures {
    return _premiumFeatures.where((f) => f.isActive).toList();
  }

  /// Get transaction statistics
  Map<String, dynamic> get transactionStats {
    if (_transactions.isEmpty) {
      return {
        'totalEarned': 0,
        'totalSpent': 0,
        'netBalance': 0,
        'transactionCount': 0,
        'earningsByType': {},
        'spendingByType': {},
      };
    }

    int totalEarned = 0;
    int totalSpent = 0;
    Map<String, int> earningsByType = {};
    Map<String, int> spendingByType = {};

    for (final transaction in _transactions) {
      if (transaction.isPositive) {
        totalEarned += transaction.amount;
        final type = transaction.type.toString().split('.').last;
        earningsByType[type] = (earningsByType[type] ?? 0) + transaction.amount;
      } else {
        totalSpent += transaction.amount;
        final type = transaction.type.toString().split('.').last;
        spendingByType[type] = (spendingByType[type] ?? 0) + transaction.amount;
      }
    }

    return {
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'netBalance': totalEarned - totalSpent,
      'transactionCount': _transactions.length,
      'earningsByType': earningsByType,
      'spendingByType': spendingByType,
    };
  }

  /// Get transactions by type
  List<CoinTransaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  /// Get transactions by date range
  List<CoinTransaction> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return _transactions
        .where((t) => t.timestamp.isAfter(start) && t.timestamp.isBefore(end))
        .toList();
  }

  /// Load transactions from storage
  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getStringList(_transactionsKey) ?? [];

      _transactions = transactionsJson
          .map((json) => CoinTransaction.fromJson(Map<String, dynamic>.from(
                  Map.fromEntries(json.split(',').map((entry) {
                final parts = entry.split(':');
                return MapEntry(parts[0], parts[1]);
              })))))
          .toList();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      _transactions = [];
    }
  }

  /// Save transactions to storage
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = _transactions
          .map((t) =>
              t.toJson().entries.map((e) => '${e.key}:${e.value}').join(','))
          .toList();

      await prefs.setStringList(_transactionsKey, transactionsJson);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  /// Load premium features from storage
  Future<void> _loadPremiumFeatures() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final featuresJson = prefs.getStringList(_premiumFeaturesKey) ?? [];

      _premiumFeatures = featuresJson
          .map((json) => UserPremiumFeature.fromJson(Map<String, dynamic>.from(
                  Map.fromEntries(json.split(',').map((entry) {
                final parts = entry.split(':');
                return MapEntry(parts[0], parts[1]);
              })))))
          .toList();
    } catch (e) {
      debugPrint('Error loading premium features: $e');
      _premiumFeatures = [];
    }
  }

  /// Save premium features to storage
  Future<void> _savePremiumFeatures() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final featuresJson = _premiumFeatures
          .map((f) =>
              f.toJson().entries.map((e) => '${e.key}:${e.value}').join(','))
          .toList();

      await prefs.setStringList(_premiumFeaturesKey, featuresJson);
    } catch (e) {
      debugPrint('Error saving premium features: $e');
    }
  }

  /// Generate unique referral code
  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  /// Reset wallet (for testing)
  Future<void> resetWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _coins = 0;
      _lastRewardTime = null;
      _lastDailyLogin = null;
      _dailyLoginStreak = 0;
      _transactions.clear();
      _premiumFeatures.clear();

      await prefs.remove(_coinsKey);
      await prefs.remove(_lastRewardTimeKey);
      await prefs.remove(_lastDailyLoginKey);
      await prefs.remove(_dailyLoginStreakKey);
      await prefs.remove(_transactionsKey);
      await prefs.remove(_premiumFeaturesKey);

      debugPrint('Enhanced wallet reset. New balance: $_coins');
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting enhanced wallet: $e');
    }
  }

  /// Get comprehensive wallet statistics
  Map<String, dynamic> get comprehensiveStats {
    final transactionStats = this.transactionStats;

    return {
      ...transactionStats,
      'currentBalance': _coins,
      'dailyLoginStreak': _dailyLoginStreak,
      'canClaimDailyLogin': canClaimDailyLoginBonus,
      'timeUntilNextDailyLogin': timeUntilNextDailyLogin?.inSeconds,
      'referralCode': _referralCode,
      'usedReferralCode': _usedReferralCode,
      'activePremiumFeatures': activePremiumFeatures.length,
      'totalPremiumFeatures': _premiumFeatures.length,
      'lastDailyLogin': _lastDailyLogin?.toIso8601String(),
      'lastRewardTime': _lastRewardTime?.toIso8601String(),
    };
  }
}
