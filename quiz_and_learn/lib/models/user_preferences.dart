class UserPreferences {
  final String userId;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String language;
  final bool showHints;
  final bool showTimer;
  final String avatarUrl;
  final String displayName;
  final DateTime lastUpdated;

  UserPreferences({
    required this.userId,
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.language = 'en',
    this.showHints = true,
    this.showTimer = true,
    this.avatarUrl = '',
    this.displayName = '',
    required this.lastUpdated,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['userId'] ?? '',
      isDarkMode: map['isDarkMode'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      language: map['language'] ?? 'en',
      showHints: map['showHints'] ?? true,
      showTimer: map['showTimer'] ?? true,
      avatarUrl: map['avatarUrl'] ?? '',
      displayName: map['displayName'] ?? '',
      lastUpdated:
          DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'language': language,
      'showHints': showHints,
      'showTimer': showTimer,
      'avatarUrl': avatarUrl,
      'displayName': displayName,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  UserPreferences copyWith({
    String? userId,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? language,
    bool? showHints,
    bool? showTimer,
    String? avatarUrl,
    String? displayName,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      language: language ?? this.language,
      showHints: showHints ?? this.showHints,
      showTimer: showTimer ?? this.showTimer,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      displayName: displayName ?? this.displayName,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}
