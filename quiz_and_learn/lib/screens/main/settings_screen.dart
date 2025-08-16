import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/user_preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _userPreferencesService = UserPreferencesService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    setState(() => _isLoading = true);

    try {
      await _userPreferencesService.initialize('default_user');
      // Remove unused variable assignment
    } catch (e) {
      // Remove print statement for production
      debugPrint('Error loading user preferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme Settings Section
                  _buildThemeSettingsSection(theme),

                  const SizedBox(height: 24),

                  // Notification Settings Section
                  _buildNotificationSettingsSection(theme),

                  const SizedBox(height: 24),

                  // Quiz Settings Section
                  _buildQuizSettingsSection(theme),

                  const SizedBox(height: 24),

                  // Data Management Section
                  _buildDataManagementSection(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildThemeSettingsSection(ThemeData theme) {
    return _buildSettingsSection(
      theme,
      title: 'Appearance',
      icon: Icons.palette,
      children: [
        _buildSwitchTile(
          theme,
          title: 'Dark Mode',
          subtitle: 'Switch between light and dark themes',
          icon: Icons.palette,
          value: _userPreferencesService.isDarkMode,
          onChanged: (value) async {
            await _userPreferencesService.setThemeMode(value);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSettingsSection(ThemeData theme) {
    return _buildSettingsSection(
      theme,
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          theme,
          title: 'Enable Notifications',
          subtitle: 'Receive push notifications',
          icon: Icons.notifications_active,
          value: _userPreferencesService.notificationsEnabled,
          onChanged: (value) async {
            await _userPreferencesService.updateNotificationSettings(
              notificationsEnabled: value,
            );
            setState(() {});
          },
        ),
        _buildSwitchTile(
          theme,
          title: 'Sound',
          subtitle: 'Play sound for notifications',
          icon: Icons.volume_up,
          value: _userPreferencesService.soundEnabled,
          onChanged: (value) async {
            await _userPreferencesService.updateNotificationSettings(
              soundEnabled: value,
            );
            setState(() {});
          },
        ),
        _buildSwitchTile(
          theme,
          title: 'Vibration',
          subtitle: 'Vibrate for notifications',
          icon: Icons.vibration,
          value: _userPreferencesService.vibrationEnabled,
          onChanged: (value) async {
            await _userPreferencesService.updateNotificationSettings(
              vibrationEnabled: value,
            );
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildQuizSettingsSection(ThemeData theme) {
    return _buildSettingsSection(
      theme,
      title: 'Quiz Settings',
      icon: Icons.quiz,
      children: [
        _buildSwitchTile(
          theme,
          title: 'Show Hints',
          subtitle: 'Display hints during quizzes',
          icon: Icons.lightbulb_outline,
          value: _userPreferencesService.showHints,
          onChanged: (value) async {
            // For now, just update the local state
            // In a real app, you'd call a method to update this preference
            setState(() {});
          },
        ),
        _buildSwitchTile(
          theme,
          title: 'Show Timer',
          subtitle: 'Display countdown timer',
          icon: Icons.timer,
          value: _userPreferencesService.showTimer,
          onChanged: (value) async {
            // For now, just update the local state
            // In a real app, you'd call a method to update this preference
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildDataManagementSection(ThemeData theme) {
    return _buildSettingsSection(
      theme,
      title: 'Data Management',
      icon: Icons.storage,
      children: [
        _buildButtonTile(
          theme,
          title: 'Clear App Data',
          subtitle: 'Remove all stored preferences and data',
          icon: Icons.delete_forever,
          onTap: () {
            _showClearDataDialog();
          },
        ),
        _buildButtonTile(
          theme,
          title: 'Export Data',
          subtitle: 'Download your app data',
          icon: Icons.download,
          onTap: () {
            _showExportDataDialog();
          },
        ),
      ],
    );
  }

  // Removed unused _buildLanguageSection method

  // Removed unused _buildResetButton method

  Widget _buildSettingsSection(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
      secondary: Icon(icon, color: theme.colorScheme.primary),
      value: value,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Removed unused _buildSliderTile method

  // Removed unused _buildDropdownTile method

  Widget _buildButtonTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
      leading: Icon(icon, color: theme.colorScheme.primary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Removed unused _showResetConfirmation method

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Data'),
        content: const Text(
          'Are you sure you want to clear all app data? This will remove all stored preferences and data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _userPreferencesService.resetToDefault();
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App data cleared.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog() {
    // This is a placeholder for actual data export functionality.
    // In a real app, you'd implement a method to serialize preferences
    // and allow the user to download it as a file.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality not yet implemented.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Removed unused _resetSettings method
}
