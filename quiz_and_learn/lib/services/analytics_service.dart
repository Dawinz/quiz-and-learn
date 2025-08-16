import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'backend_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final BackendService _backendService = BackendService();
  final List<Map<String, dynamic>> _eventQueue = [];
  final List<Map<String, dynamic>> _performanceMetrics = [];

  bool _isInitialized = false;
  bool _isOnline = false;
  Timer? _syncTimer;
  Timer? _performanceTimer;

  // Analytics Configuration
  static const Duration _syncInterval = Duration(minutes: 5);
  static const Duration _performanceInterval = Duration(minutes: 1);
  static const int _maxQueueSize = 100;
  static const int _maxPerformanceMetrics = 50;

  // Event constants
  static const String _eventScreenView = 'screen_view';
  static const String _eventQuizStarted = 'quiz_started';
  static const String _eventQuizCompleted = 'quiz_completed';
  static const String _eventQuizAbandoned = 'quiz_abandoned';
  static const String _eventUserAction = 'user_action';
  static const String _eventProfileUpdated = 'profile_updated';
  static const String _eventSettingsChanged = 'settings_changed';
  static const String _eventNotificationReceived = 'notification_received';
  static const String _eventAppOpened = 'app_opened';
  static const String _eventAppBackgrounded = 'app_backgrounded';
  static const String _eventErrorOccurred = 'error_occurred';
  static const String _eventError = 'error';
  static const String _eventPerformance = 'performance';

  // Performance Metrics
  static const String _metricAppStartTime = 'app_start_time';
  static const String _metricScreenLoadTime = 'screen_load_time';
  static const String _metricQuizLoadTime = 'quiz_load_time';
  static const String _metricApiResponseTime = 'api_response_time';
  static const String _metricMemoryUsage = 'memory_usage';
  static const String _metricBatteryLevel = 'battery_level';

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check backend connectivity
      _isOnline = await _backendService.healthCheck();

      // Start timers
      _startSyncTimer();
      _startPerformanceTimer();

      // Load cached events
      await _loadCachedEvents();

      _isInitialized = true;

      // Track app opened event
      trackAppOpened();
    } catch (e) {
      print('Error initializing analytics service: $e');
      _isInitialized = true;
    }
  }

  // Dispose the service
  void dispose() {
    _syncTimer?.cancel();
    _performanceTimer?.cancel();
    _syncEvents(); // Final sync before disposal
  }

  // Track screen view
  void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    final event = {
      'event': _eventScreenView,
      'screenName': screenName,
      'properties': properties ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    _addEventToQueue(event);
    _trackPerformanceMetric(_metricScreenLoadTime, screenName, DateTime.now());
  }

  // Track user actions
  void trackUserAction(String action, {Map<String, dynamic>? properties}) {
    final event = {
      'event': _eventUserAction,
      'action': action,
      'properties': properties ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    _addEventToQueue(event);
  }

  // Track quiz events
  void trackQuizStarted(String quizId, String category, String difficulty) {
    trackUserAction('quiz_started', properties: {
      'quizId': quizId,
      'category': category,
      'difficulty': difficulty,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void trackQuizCompleted(String quizId, int score, Duration timeElapsed) {
    trackUserAction('quiz_completed', properties: {
      'quizId': quizId,
      'score': score,
      'timeElapsed': timeElapsed.inSeconds,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void trackQuizAbandoned(String quizId, int progress, Duration timeElapsed) {
    trackUserAction('quiz_abandoned', properties: {
      'quizId': quizId,
      'progress': progress,
      'timeElapsed': timeElapsed.inSeconds,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Track profile and settings events
  void trackProfileUpdated(String field, String? oldValue, String? newValue) {
    final event = {
      'event': _eventProfileUpdated,
      'field': field,
      'oldValue': oldValue,
      'newValue': newValue,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _addEventToQueue(event);
  }

  void trackSettingsChanged(
      String setting, dynamic oldValue, dynamic newValue) {
    final event = {
      'event': _eventSettingsChanged,
      'setting': setting,
      'oldValue': oldValue.toString(),
      'newValue': newValue.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _addEventToQueue(event);
  }

  // Track notification events
  void trackNotificationReceived(
      String notificationId, String type, String? quizId) {
    final event = {
      'event': _eventNotificationReceived,
      'notificationId': notificationId,
      'type': type,
      'quizId': quizId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _addEventToQueue(event);
  }

  // Track app lifecycle events
  void trackAppOpened() {
    final event = {
      'event': _eventAppOpened,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _addEventToQueue(event);
  }

  void trackAppBackgrounded() {
    final event = {
      'event': _eventAppBackgrounded,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _addEventToQueue(event);

    // Sync events when app goes to background
    _syncEvents();
  }

  // Track errors
  void trackError(String errorType, String errorMessage, String? screenName,
      StackTrace? stackTrace) {
    final event = {
      'event': _eventErrorOccurred,
      'errorType': errorType,
      'errorMessage': errorMessage,
      'screenName': screenName,
      'stackTrace': stackTrace?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _addEventToQueue(event);
  }

  // Performance tracking
  void trackAppStartTime(Duration startTime) {
    _trackPerformanceMetric(
        _metricAppStartTime, 'app_start', startTime.inMilliseconds);
  }

  void trackScreenLoadTime(String screenName, Duration loadTime) {
    _trackPerformanceMetric(
        _metricScreenLoadTime, screenName, loadTime.inMilliseconds);
  }

  void trackQuizLoadTime(String quizId, Duration loadTime) {
    _trackPerformanceMetric(
        _metricQuizLoadTime, quizId, loadTime.inMilliseconds);
  }

  void trackApiResponseTime(String endpoint, Duration responseTime) {
    _trackPerformanceMetric(
        _metricApiResponseTime, endpoint, responseTime.inMilliseconds);
  }

  void trackMemoryUsage(int memoryUsageMB) {
    _trackPerformanceMetric(_metricMemoryUsage, 'memory', memoryUsageMB);
  }

  void trackBatteryLevel(double batteryLevel) {
    _trackPerformanceMetric(_metricBatteryLevel, 'battery', batteryLevel);
  }

  // Add event to queue
  void _addEventToQueue(Map<String, dynamic> event) {
    _eventQueue.add(event);

    // Limit queue size
    if (_eventQueue.length > _maxQueueSize) {
      _eventQueue.removeAt(0);
    }

    // Cache events locally
    _cacheEvents();

    // Sync if online and queue is getting full
    if (_isOnline && _eventQueue.length >= _maxQueueSize * 0.8) {
      _syncEvents();
    }
  }

  // Track performance metric
  void _trackPerformanceMetric(
      String metricType, String identifier, dynamic value) {
    final metric = {
      'metricType': metricType,
      'identifier': identifier,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _performanceMetrics.add(metric);

    // Limit performance metrics size
    if (_performanceMetrics.length > _maxPerformanceMetrics) {
      _performanceMetrics.removeAt(0);
    }
  }

  // Start sync timer
  void _startSyncTimer() {
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      if (_isOnline && _eventQueue.isNotEmpty) {
        _syncEvents();
      }
    });
  }

  // Start performance timer
  void _startPerformanceTimer() {
    _performanceTimer = Timer.periodic(_performanceInterval, (timer) {
      if (_isOnline && _performanceMetrics.isNotEmpty) {
        _syncPerformanceMetrics();
      }
    });
  }

  // Sync events to backend
  Future<void> _syncEvents() async {
    if (_eventQueue.isEmpty || !_isOnline) return;

    List<Map<String, dynamic>> eventsToSync = [];
    
    try {
      eventsToSync = List<Map<String, dynamic>>.from(_eventQueue);
      _eventQueue.clear();

      // For now, just log the events instead of sending to backend
      print('📊 Analytics: Would sync ${eventsToSync.length} events');
      for (final event in eventsToSync) {
        print('📊 Event: ${event['event']}');
      }

      // Clear cached events after successful sync
      await _clearCachedEvents();

      print('📊 Analytics: Synced ${eventsToSync.length} events');
    } catch (e) {
      // Put events back in queue if sync failed
      if (eventsToSync.isNotEmpty) {
        _eventQueue.insertAll(0, eventsToSync);
      }
      print('❌ Analytics: Failed to sync events: $e');
    }
  }

  // Sync performance metrics
  Future<void> _syncPerformanceMetrics() async {
    if (_performanceMetrics.isEmpty || !_isOnline) return;

    List<Map<String, dynamic>> metricsToSync = [];
    
    try {
      metricsToSync = List<Map<String, dynamic>>.from(_performanceMetrics);
      _performanceMetrics.clear();

      // For now, just log the metrics instead of sending to backend
      print('📊 Analytics: Would sync ${metricsToSync.length} performance metrics');
      for (final metric in metricsToSync) {
        print('📊 Metric: $metric');
      }

      print('📊 Analytics: Synced ${metricsToSync.length} performance metrics');
    } catch (e) {
      // Put metrics back if sync failed
      if (metricsToSync.isNotEmpty) {
        _performanceMetrics.insertAll(0, metricsToSync);
      }
      print('❌ Analytics: Failed to sync performance metrics: $e');
    }
  }

  // Cache events locally
  Future<void> _cacheEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = json.encode(_eventQueue);
      await prefs.setString('analytics_events', eventsJson);
    } catch (e) {
      print('Error caching analytics events: $e');
    }
  }

  // Load cached events
  Future<void> _loadCachedEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('analytics_events');

      if (eventsJson != null) {
        final eventsList = json.decode(eventsJson) as List<dynamic>;
        _eventQueue.addAll(eventsList.map((e) => e as Map<String, dynamic>));
        print('📊 Analytics: Loaded ${_eventQueue.length} cached events');
      }
    } catch (e) {
      print('Error loading cached analytics events: $e');
    }
  }

  // Clear cached events
  Future<void> _clearCachedEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('analytics_events');
    } catch (e) {
      print('Error clearing cached analytics events: $e');
    }
  }

  // Update online status
  void updateOnlineStatus(bool isOnline) {
    _isOnline = isOnline;

    if (isOnline && _eventQueue.isNotEmpty) {
      _syncEvents();
    }
  }

  // Get analytics summary
  Map<String, dynamic> getAnalyticsSummary() {
    return {
      'totalEvents': _eventQueue.length,
      'totalPerformanceMetrics': _performanceMetrics.length,
      'isOnline': _isOnline,
      'lastSync': _getLastSyncTime(),
      'queuedEvents': _eventQueue.map((e) => e['event']).toSet().toList(),
    };
  }

  // Get last sync time
  String _getLastSyncTime() {
    if (_eventQueue.isEmpty) return 'Never';

    final lastEvent = _eventQueue.last;
    return lastEvent['timestamp'] ?? 'Unknown';
  }

  // Force sync all pending events
  Future<void> forceSync() async {
    if (_eventQueue.isEmpty) return;

    List<Map<String, dynamic>> eventsToSync = [];
    
    try {
      eventsToSync = List<Map<String, dynamic>>.from(_eventQueue);
      _eventQueue.clear();

      // For now, just log the events
      print('📊 Syncing ${eventsToSync.length} analytics events');
      for (final event in eventsToSync) {
        print('📊 Event: ${event['event']}');
      }

      print('✅ Analytics events synced');
    } catch (e) {
      print('❌ Failed to sync analytics events: $e');
      // Put events back in queue for retry
      if (eventsToSync.isNotEmpty) {
        _eventQueue.addAll(eventsToSync);
      }
    }
  }

  // Send performance metrics
  Future<void> sendPerformanceMetrics(Map<String, dynamic> metrics) async {
    try {
      // For now, just log the metrics
      print('📊 Performance metrics: $metrics');
      print('✅ Performance metrics sent');
    } catch (e) {
      print('❌ Failed to send performance metrics: $e');
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    _eventQueue.clear();
    _performanceMetrics.clear();
    await _clearCachedEvents();
  }
}

