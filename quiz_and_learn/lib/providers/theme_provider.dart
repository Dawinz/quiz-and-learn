import 'package:flutter/material.dart';
import '../services/user_preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  final UserPreferencesService _preferencesService = UserPreferencesService();

  bool _isDarkMode = false;
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  // Theme data
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      scaffoldBackgroundColor: Colors.grey[50],
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF2D2D2D),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF3D3D3D),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
    );
  }

  // Get current theme
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  // Initialize theme
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    try {
      await _preferencesService.initialize(userId);
      _isDarkMode = _preferencesService.isDarkMode;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing theme provider: $e');
      _isInitialized = true;
    }
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _preferencesService.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  // Set theme mode
  Future<void> setThemeMode(bool isDarkMode) async {
    if (_isDarkMode == isDarkMode) return;

    _isDarkMode = isDarkMode;
    await _preferencesService.setThemeMode(isDarkMode);
    notifyListeners();
  }

  // Get theme mode string
  String get themeModeString => _isDarkMode ? 'Dark' : 'Light';

  // Get theme icon
  IconData get themeIcon => _isDarkMode ? Icons.light_mode : Icons.dark_mode;

  // Get theme description
  String get themeDescription =>
      _isDarkMode ? 'Switch to light theme' : 'Switch to dark theme';

  // Get color scheme
  ColorScheme get colorScheme => currentTheme.colorScheme;

  // Get text theme
  TextTheme get textTheme => currentTheme.textTheme;

  // Get primary color
  Color get primaryColor => colorScheme.primary;

  // Get background color
  Color get backgroundColor => colorScheme.surface;

  // Get surface color
  Color get surfaceColor => colorScheme.surface;

  // Get on surface color
  Color get onSurfaceColor => colorScheme.onSurface;

  // Get card color
  Color get cardColor => colorScheme.surface;

  // Get error color
  Color get errorColor => colorScheme.error;

  // Get success color
  Color get successColor => Colors.green;

  // Get warning color
  Color get warningColor => Colors.orange;

  // Get info color
  Color get infoColor => Colors.blue;

  // Get disabled color
  Color get disabledColor => colorScheme.onSurface.withOpacity(0.38);

  // Get divider color
  Color get dividerColor => colorScheme.outline.withOpacity(0.12);

  // Get shadow color
  Color get shadowColor => _isDarkMode
      ? Colors.black.withOpacity(0.3)
      : Colors.black.withOpacity(0.1);

  // Get elevation
  double get elevation => _isDarkMode ? 4.0 : 2.0;

  // Get border radius
  double get borderRadius => 12.0;

  // Get animation duration
  Duration get animationDuration => const Duration(milliseconds: 300);

  // Get animation curve
  Curve get animationCurve => Curves.easeInOut;

  // Get responsive breakpoints
  double get mobileBreakpoint => 600;
  double get tabletBreakpoint => 900;
  double get desktopBreakpoint => 1200;

  // Check if device is mobile
  bool isMobile(double width) => width < mobileBreakpoint;

  // Check if device is tablet
  bool isTablet(double width) =>
      width >= mobileBreakpoint && width < tabletBreakpoint;

  // Check if device is desktop
  bool isDesktop(double width) => width >= desktopBreakpoint;

  // Get responsive padding
  EdgeInsets getResponsivePadding(double width) {
    if (isMobile(width)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(width)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  // Get responsive margin
  EdgeInsets getResponsiveMargin(double width) {
    if (isMobile(width)) {
      return const EdgeInsets.all(8.0);
    } else if (isTablet(width)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  // Get responsive font size
  double getResponsiveFontSize(double baseSize, double width) {
    if (isMobile(width)) {
      return baseSize;
    } else if (isTablet(width)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }
}
