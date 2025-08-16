import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';

class UserPreferencesService {
  static final UserPreferencesService _instance =
      UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  static const String _prefsKey = 'user_preferences';
  static const String _themeKey = 'theme_mode';
  static const String _avatarKey = 'user_avatar';
  static const String _displayNameKey = 'display_name';

  UserPreferences? _currentPreferences;
  bool _isInitialized = false;

  // Get current preferences
  UserPreferences? get currentPreferences => _currentPreferences;
  bool get isInitialized => _isInitialized;

  // Initialize the service
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('${_prefsKey}_$userId');

      if (prefsJson != null) {
        final prefsMap = json.decode(prefsJson) as Map<String, dynamic>;
        _currentPreferences = UserPreferences.fromMap(prefsMap);
      } else {
        // Create default preferences
        _currentPreferences = UserPreferences(
          userId: userId,
          lastUpdated: DateTime.now(),
        );
        await _savePreferences();
      }

      _isInitialized = true;
    } catch (e) {
      // Fallback to default preferences
      _currentPreferences = UserPreferences(
        userId: userId,
        lastUpdated: DateTime.now(),
      );
      _isInitialized = true;
    }
  }

  // Save preferences to SharedPreferences
  Future<void> _savePreferences() async {
    if (_currentPreferences == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = json.encode(_currentPreferences!.toMap());
      await prefs.setString(
          '${_prefsKey}_${_currentPreferences!.userId}', prefsJson);
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  // Update theme mode
  Future<void> setThemeMode(bool isDarkMode) async {
    if (_currentPreferences == null) return;

    _currentPreferences = _currentPreferences!.copyWith(
      isDarkMode: isDarkMode,
    );
    await _savePreferences();
  }

  // Update notification settings
  Future<void> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) async {
    if (_currentPreferences == null) return;

    _currentPreferences = _currentPreferences!.copyWith(
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
    );
    await _savePreferences();
  }

  // Update language
  Future<void> setLanguage(String language) async {
    if (_currentPreferences == null) return;

    _currentPreferences = _currentPreferences!.copyWith(
      language: language,
    );
    await _savePreferences();
  }

  // Update avatar
  Future<void> setAvatar(String avatarUrl) async {
    if (_currentPreferences == null) return;

    _currentPreferences = _currentPreferences!.copyWith(
      avatarUrl: avatarUrl,
    );
    await _savePreferences();
  }

  // Update display name
  Future<void> setDisplayName(String displayName) async {
    if (_currentPreferences == null) return;

    _currentPreferences = _currentPreferences!.copyWith(
      displayName: displayName,
    );
    await _savePreferences();
  }

  // Get theme mode
  bool get isDarkMode => _currentPreferences?.isDarkMode ?? false;

  // Get notification settings
  bool get notificationsEnabled =>
      _currentPreferences?.notificationsEnabled ?? true;
  bool get soundEnabled => _currentPreferences?.soundEnabled ?? true;
  bool get vibrationEnabled => _currentPreferences?.vibrationEnabled ?? true;

  // Get quiz settings
  bool get showHints => _currentPreferences?.showHints ?? true;
  bool get showTimer => _currentPreferences?.showTimer ?? true;

  // Get language
  String get language => _currentPreferences?.language ?? 'en';

  // Get avatar
  String get avatarUrl => _currentPreferences?.avatarUrl ?? '';

  // Get display name
  String get displayName => _currentPreferences?.displayName ?? '';

  // Reset preferences to default
  Future<void> resetToDefault() async {
    if (_currentPreferences == null) return;

    _currentPreferences = UserPreferences(
      userId: _currentPreferences!.userId,
      lastUpdated: DateTime.now(),
    );
    await _savePreferences();
  }

  // Export preferences
  Map<String, dynamic> exportPreferences() {
    if (_currentPreferences == null) return {};
    return _currentPreferences!.toMap();
  }

  // Import preferences
  Future<void> importPreferences(Map<String, dynamic> prefsMap) async {
    try {
      _currentPreferences = UserPreferences.fromMap(prefsMap);
      await _savePreferences();
    } catch (e) {
      print('Error importing preferences: $e');
    }
  }

  // Clear all preferences
  Future<void> clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentPreferences != null) {
        await prefs.remove('${_prefsKey}_${_currentPreferences!.userId}');
      }
      _currentPreferences = null;
      _isInitialized = false;
    } catch (e) {
      print('Error clearing preferences: $e');
    }
  }
}
