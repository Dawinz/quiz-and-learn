import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../security/security_guard.dart';
import 'outbox_service.dart';

class SecureWalletService extends ChangeNotifier {
  static SecureWalletService? _instance;
  static SecureWalletService get instance =>
      _instance ??= SecureWalletService._();

  SecureWalletService._();

  static const String _coinsKey = 'user_coins';
  static const String _lastRewardTimeKey = 'last_reward_time';
  static const String _pendingRewardsKey = 'pending_rewards';

  int _coins = 0;
  DateTime? _lastRewardTime;
  List<Map<String, dynamic>> _pendingRewards = [];
  bool _isInitialized = false;

  late final SecurityGuard _securityGuard;
  late final OutboxService _outboxService;

  /// Get current coin balance
  int get coins => _coins;

  /// Get last reward time
  DateTime? get lastRewardTime => _lastRewardTime;

  /// Get pending rewards
  List<Map<String, dynamic>> get pendingRewards => List.from(_pendingRewards);

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the secure wallet service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize dependencies
      _securityGuard = SecurityGuard();
      await _securityGuard.initialize();

      _outboxService = OutboxService();
      await _outboxService.initialize();

      // Load existing data
      final prefs = await SharedPreferences.getInstance();
      _coins = prefs.getInt(_coinsKey) ?? 0;

      final lastRewardTimestamp = prefs.getInt(_lastRewardTimeKey);
      if (lastRewardTimestamp != null) {
        _lastRewardTime =
            DateTime.fromMillisecondsSinceEpoch(lastRewardTimestamp);
      }

      // Load pending rewards
      final pendingRewardsJson = prefs.getString(_pendingRewardsKey);
      if (pendingRewardsJson != null) {
        _pendingRewards = List<Map<String, dynamic>>.from(
          jsonDecode(pendingRewardsJson),
        );
      }

      _isInitialized = true;
      notifyListeners();
      debugPrint('SecureWalletService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing SecureWalletService: $e');
      _isInitialized = true;
    }
  }

  /// Request coins (creates pending reward)
  Future<bool> requestCoins(int amount, {String source = 'unknown'}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (amount <= 0) return false;

    try {
      // Check security before allowing reward
      final canClaim = await _securityGuard.canClaimReward();
      if (!canClaim) {
        debugPrint('Reward blocked by security guard');
        return false;
      }

      // Create pending reward
      final rewardId = _generateRewardId();
      final pendingReward = {
        'id': rewardId,
        'amount': amount,
        'source': source,
        'requestedAt': DateTime.now().toIso8601String(),
        'status': 'pending',
      };

      _pendingRewards.add(pendingReward);
      await _savePendingRewards();

      // Submit to outbox for server processing
      final outboxResult = await _outboxService.submitWrite(
        endpoint: '/v1/rewards/request',
        data: {
          'rewardId': rewardId,
          'amount': amount,
          'source': source,
          'deviceFingerprint': _securityGuard.getDeviceFingerprint(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        operationType: 'reward_request',
      );

      if (outboxResult.success) {
        debugPrint('Reward request submitted successfully: $rewardId');
        notifyListeners();
        return true;
      } else {
        debugPrint('Failed to submit reward request: ${outboxResult.error}');
        // Remove from pending if outbox submission failed
        _pendingRewards.removeWhere((r) => r['id'] == rewardId);
        await _savePendingRewards();
        return false;
      }
    } catch (e) {
      debugPrint('Error requesting coins: $e');
      return false;
    }
  }

  /// Confirm reward from server
  Future<bool> confirmReward(String rewardId, int amount) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Find the pending reward
      final rewardIndex =
          _pendingRewards.indexWhere((r) => r['id'] == rewardId);
      if (rewardIndex == -1) {
        debugPrint('Reward not found: $rewardId');
        return false;
      }

      final reward = _pendingRewards[rewardIndex];

      // Update reward status
      reward['status'] = 'confirmed';
      reward['confirmedAt'] = DateTime.now().toIso8601String();
      reward['confirmedAmount'] = amount;

      // Add coins to balance
      _coins += amount;
      _lastRewardTime = DateTime.now();

      // Save updated data
      await _saveWalletData();
      await _savePendingRewards();

      debugPrint('Reward confirmed: $rewardId, amount: $amount');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error confirming reward: $e');
      return false;
    }
  }

  /// Reject reward from server
  Future<bool> rejectReward(String rewardId, String reason) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Find the pending reward
      final rewardIndex =
          _pendingRewards.indexWhere((r) => r['id'] == rewardId);
      if (rewardIndex == -1) {
        debugPrint('Reward not found: $rewardId');
        return false;
      }

      final reward = _pendingRewards[rewardIndex];

      // Update reward status
      reward['status'] = 'rejected';
      reward['rejectedAt'] = DateTime.now().toIso8601String();
      reward['rejectionReason'] = reason;

      // Save updated pending rewards
      await _savePendingRewards();

      debugPrint('Reward rejected: $rewardId, reason: $reason');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error rejecting reward: $e');
      return false;
    }
  }

  /// Remove coins from wallet (for purchases)
  Future<bool> removeCoins(int amount, {String source = 'unknown'}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (amount <= 0 || _coins < amount) return false;

    try {
      // Submit removal to outbox
      final outboxResult = await _outboxService.submitWrite(
        endpoint: '/v1/wallet/remove',
        data: {
          'amount': amount,
          'source': source,
          'deviceFingerprint': _securityGuard.getDeviceFingerprint(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        operationType: 'coin_removal',
      );

      if (outboxResult.success) {
        // Update local balance
        _coins -= amount;
        await _saveWalletData();

        debugPrint('Removed $amount coins from $source. New balance: $_coins');
        notifyListeners();
        return true;
      } else {
        debugPrint('Failed to submit coin removal: ${outboxResult.error}');
        return false;
      }
    } catch (e) {
      debugPrint('Error removing coins: $e');
      return false;
    }
  }

  /// Get wallet statistics
  Map<String, dynamic> get statistics {
    return {
      'currentBalance': _coins,
      'lastRewardTime': _lastRewardTime?.toIso8601String(),
      'pendingRewardsCount': _pendingRewards.length,
      'pendingRewardsTotal': _pendingRewards
          .where((r) => r['status'] == 'pending')
          .fold(0, (sum, r) => sum + (r['amount'] as int)),
      'isInitialized': _isInitialized,
    };
  }

  /// Get pending rewards by status
  List<Map<String, dynamic>> getPendingRewardsByStatus(String status) {
    return _pendingRewards.where((r) => r['status'] == status).toList();
  }

  /// Clear old completed rewards
  Future<void> clearOldRewards() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      _pendingRewards.removeWhere((reward) {
        if (reward['status'] == 'confirmed' || reward['status'] == 'rejected') {
          final timestamp = DateTime.tryParse(
              reward['confirmedAt'] ?? reward['rejectedAt'] ?? '');
          return timestamp != null && timestamp.isBefore(cutoffDate);
        }
        return false;
      });

      await _savePendingRewards();
      debugPrint('Cleared old completed rewards');
    } catch (e) {
      debugPrint('Error clearing old rewards: $e');
    }
  }

  /// Reset wallet (for testing)
  Future<void> resetWallet() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _coins = 0;
      _lastRewardTime = null;
      _pendingRewards.clear();

      await prefs.remove(_coinsKey);
      await prefs.remove(_lastRewardTimeKey);
      await prefs.remove(_pendingRewardsKey);

      debugPrint('Wallet reset. New balance: $_coins');
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting wallet: $e');
    }
  }

  // Helper methods
  String _generateRewardId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 1000000;
    return 'reward_${timestamp}_$random';
  }

  Future<void> _saveWalletData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_coinsKey, _coins);

      if (_lastRewardTime != null) {
        await prefs.setInt(
            _lastRewardTimeKey, _lastRewardTime!.millisecondsSinceEpoch);
      }
    } catch (e) {
      debugPrint('Error saving wallet data: $e');
    }
  }

  Future<void> _savePendingRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingRewardsKey, jsonEncode(_pendingRewards));
    } catch (e) {
      debugPrint('Error saving pending rewards: $e');
    }
  }
}
