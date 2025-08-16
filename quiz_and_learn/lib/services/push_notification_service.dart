import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final ConfigService _configService = ConfigService();

  bool _isInitialized = false;
  Map<String, dynamic> _notificationSettings = {};
  List<Map<String, dynamic>> _notificationHistory = [];

  // Get current instance
  static PushNotificationService get instance => _instance;

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _configService.initialize();
      await _loadNotificationSettings();
      await _loadNotificationHistory();

      _isInitialized = true;
      print('✅ Push notification service initialized');
    } catch (e) {
      print('❌ Failed to initialize push notification service: $e');
    }
  }

  // Load notification settings
  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('notification_settings');
      
      if (settingsJson != null) {
        _notificationSettings = json.decode(settingsJson);
      } else {
        // Default settings
        _notificationSettings = {
          'quiz_reminders': true,
          'achievements': true,
          'new_quizzes': true,
          'daily_motivation': true,
          'sound_enabled': true,
          'vibration_enabled': true,
        };
        await _saveNotificationSettings();
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  // Save notification settings
  Future<void> _saveNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notification_settings', json.encode(_notificationSettings));
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  // Load notification history
  Future<void> _loadNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('notification_history');
      
      if (historyJson != null) {
        final historyList = json.decode(historyJson) as List<dynamic>;
        _notificationHistory = historyList.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('Error loading notification history: $e');
    }
  }

  // Save notification history
  Future<void> _saveNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notification_history', json.encode(_notificationHistory));
    } catch (e) {
      print('Error saving notification history: $e');
    }
  }

  // Send quiz reminder notification
  Future<void> sendQuizReminder(String quizId, String quizTitle) async {
    if (!_notificationSettings['quiz_reminders'] ?? true) return;

    try {
      // Log the notification
      print('📱 Quiz reminder sent: $quizTitle');

      // Add to history
      _addToHistory('quiz_reminder', {
        'quizId': quizId,
        'quizTitle': quizTitle,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Failed to send quiz reminder: $e');
    }
  }

  // Send achievement notification
  Future<void> sendAchievementNotification(String achievementId, String achievementTitle, String description) async {
    if (!_notificationSettings['achievements'] ?? true) return;

    try {
      // Log the notification
      print('🏆 Achievement notification sent: $achievementTitle');

      // Add to history
      _addToHistory('achievement', {
        'achievementId': achievementId,
        'achievementTitle': achievementTitle,
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Failed to send achievement notification: $e');
    }
  }

  // Send new quiz notification
  Future<void> sendNewQuizNotification(String quizId, String quizTitle, String category) async {
    if (!_notificationSettings['new_quizzes'] ?? true) return;

    try {
      // Log the notification
      print('📚 New quiz notification sent: $quizTitle');

      // Add to history
      _addToHistory('new_quiz', {
        'quizId': quizId,
        'quizTitle': quizTitle,
        'category': category,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Failed to send new quiz notification: $e');
    }
  }

  // Send daily motivation notification
  Future<void> sendDailyMotivationNotification(String message) async {
    if (!_notificationSettings['daily_motivation'] ?? true) return;

    try {
      // Log the notification
      print('💪 Daily motivation sent: $message');

      // Add to history
      _addToHistory('daily_motivation', {
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Failed to send daily motivation: $e');
    }
  }

  // Add notification to history
  void _addToHistory(String type, Map<String, dynamic> data) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _notificationHistory.add(notification);

    // Keep only last 100 notifications
    if (_notificationHistory.length > 100) {
      _notificationHistory = _notificationHistory.sublist(_notificationHistory.length - 100);
    }

    _saveNotificationHistory();
  }

  // Get notification settings
  Map<String, dynamic> getNotificationSettings() {
    return Map.from(_notificationSettings);
  }

  // Update notification settings
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    _notificationSettings.addAll(settings);
    await _saveNotificationSettings();

    // Log the settings change
    print('⚙️ Notification settings updated: $settings');
  }

  // Get notification history
  List<Map<String, dynamic>> getNotificationHistory() {
    return List.from(_notificationHistory);
  }

  // Clear notification history
  Future<void> clearNotificationHistory() async {
    _notificationHistory.clear();
    await _saveNotificationHistory();
    print('🗑️ Notification history cleared');
  }

  // Test notification
  Future<void> sendTestNotification() async {
    try {
      // Log the test notification
      print('🧪 Test notification sent');

      // Add to history
      _addToHistory('test', {
        'message': 'Test notification sent',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Failed to send test notification: $e');
    }
  }

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Dispose resources
  void dispose() {
    // Clean up resources if needed
  }
}
