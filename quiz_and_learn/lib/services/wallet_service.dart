import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletService extends ChangeNotifier {
  static WalletService? _instance;
  static WalletService get instance => _instance ??= WalletService._();

  WalletService._();

  static const String _coinsKey = 'user_coins';
  static const String _lastRewardTimeKey = 'last_reward_time';
  
  int _coins = 0;
  DateTime? _lastRewardTime;
  bool _isInitialized = false;

  /// Get current coin balance
  int get coins => _coins;

  /// Get last reward time
  DateTime? get lastRewardTime => _lastRewardTime;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the wallet service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _coins = prefs.getInt(_coinsKey) ?? 0;
      
      final lastRewardTimestamp = prefs.getInt(_lastRewardTimeKey);
      if (lastRewardTimestamp != null) {
        _lastRewardTime = DateTime.fromMillisecondsSinceEpoch(lastRewardTimestamp);
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing wallet service: $e');
      _isInitialized = true;
    }
  }

  /// Add coins to wallet
  Future<bool> addCoins(int amount, {String source = 'unknown'}) async {
    if (amount <= 0) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      _coins += amount;
      
      await prefs.setInt(_coinsKey, _coins);
      
      debugPrint('Added $amount coins from $source. New balance: $_coins');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding coins: $e');
      return false;
    }
  }

  /// Remove coins from wallet
  Future<bool> removeCoins(int amount, {String source = 'unknown'}) async {
    if (amount <= 0 || _coins < amount) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      _coins -= amount;
      
      await prefs.setInt(_coinsKey, _coins);
      
      debugPrint('Removed $amount coins from $source. New balance: $_coins');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error removing coins: $e');
      return false;
    }
  }

  /// Add coins from rewarded video ad
  Future<bool> addRewardedVideoCoins(int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      
      // Check if enough time has passed since last reward
      if (_lastRewardTime != null) {
        final timeSinceLastReward = now.difference(_lastRewardTime!);
        if (timeSinceLastReward.inMinutes < 1) {
          debugPrint('Reward too soon after last reward. Skipping.');
          return false;
        }
      }
      
      // Add coins and update last reward time
      _coins += coins;
      _lastRewardTime = now;
      
      await prefs.setInt(_coinsKey, _coins);
      await prefs.setInt(_lastRewardTimeKey, now.millisecondsSinceEpoch);
      
      debugPrint('Added $coins coins from rewarded video. New balance: $_coins');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding rewarded video coins: $e');
      return false;
    }
  }

  /// Check if user can receive reward
  bool get canReceiveReward {
    if (_lastRewardTime == null) return true;
    
    final timeSinceLastReward = DateTime.now().difference(_lastRewardTime!);
    return timeSinceLastReward.inMinutes >= 1;
  }

  /// Get time until next reward is available
  Duration? get timeUntilNextReward {
    if (_lastRewardTime == null) return Duration.zero;
    
    final timeSinceLastReward = DateTime.now().difference(_lastRewardTime!);
    final minutesUntilNext = 1 - timeSinceLastReward.inMinutes;
    
    if (minutesUntilNext <= 0) return Duration.zero;
    
    return Duration(minutes: minutesUntilNext);
  }

  /// Reset wallet (for testing)
  Future<void> resetWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _coins = 0;
      _lastRewardTime = null;
      
      await prefs.remove(_coinsKey);
      await prefs.remove(_lastRewardTimeKey);
      
      debugPrint('Wallet reset. New balance: $_coins');
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting wallet: $e');
    }
  }

  /// Get wallet statistics
  Map<String, dynamic> get statistics {
    return {
      'currentBalance': _coins,
      'lastRewardTime': _lastRewardTime?.toIso8601String(),
      'canReceiveReward': canReceiveReward,
      'timeUntilNextReward': timeUntilNextReward?.inSeconds,
      'isInitialized': _isInitialized,
    };
  }
}
