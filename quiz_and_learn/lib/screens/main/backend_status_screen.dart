import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/backend_service.dart';
import '../../services/data_sync_service.dart';
import '../../services/push_notification_service.dart';
import '../../services/wallet_service.dart';

class BackendStatusScreen extends StatefulWidget {
  const BackendStatusScreen({super.key});

  @override
  State<BackendStatusScreen> createState() => _BackendStatusScreenState();
}

class _BackendStatusScreenState extends State<BackendStatusScreen> {
  final BackendService _backendService = BackendService();
  final DataSyncService _dataSyncService = DataSyncService();
  final PushNotificationService _pushNotificationService = PushNotificationService();
  final WalletService _walletService = WalletService.instance;

  Map<String, dynamic> _backendStatus = {};
  Map<String, dynamic> _syncStatus = {};
  Map<String, dynamic> _notificationStatus = {};
  Map<String, dynamic> _walletStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);

    try {
      // Load backend status
      _backendStatus = await _backendService.getConnectionStatus();
      
      // Load sync status
      _syncStatus = await _dataSyncService.getSyncStatus();
      
      // Load notification status
      _notificationStatus = {
        'isInitialized': _pushNotificationService.isInitialized,
        'settings': _pushNotificationService.getNotificationSettings(),
        'historyCount': _pushNotificationService.getNotificationHistory().length,
      };
      
      // Load wallet status
      _walletStatus = {
        'isInitialized': _walletService.isInitialized,
        'coins': _walletService.coins,
        'canReceiveReward': _walletService.canReceiveReward,
      };

      setState(() {});
    } catch (e) {
      print('Error loading status: $e');
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
        title: const Text('Backend Status'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatus,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackendStatusCard(theme),
                    const SizedBox(height: 16),
                    _buildSyncStatusCard(theme),
                    const SizedBox(height: 16),
                    _buildNotificationStatusCard(theme),
                    const SizedBox(height: 16),
                    _buildWalletStatusCard(theme),
                    const SizedBox(height: 16),
                    _buildActionsCard(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBackendStatusCard(ThemeData theme) {
    final isOnline = _backendStatus['connected'] ?? false;
    final baseUrl = _backendStatus['baseUrl'] ?? 'Unknown';
    final isAuthenticated = _backendStatus['authenticated'] ?? false;

    return _buildStatusCard(
      theme,
      title: 'Backend Connection',
      icon: Icons.cloud,
      color: isOnline ? Colors.green : Colors.red,
      children: [
        _buildStatusRow('Status', isOnline ? 'Online' : 'Offline'),
        _buildStatusRow('Base URL', baseUrl),
        _buildStatusRow('Authenticated', isAuthenticated ? 'Yes' : 'No'),
        if (_backendStatus['timestamp'] != null)
          _buildStatusRow('Last Check', _formatTimestamp(_backendStatus['timestamp'])),
      ],
    );
  }

  Widget _buildSyncStatusCard(ThemeData theme) {
    final isOnline = _syncStatus['isOnline'] ?? false;
    final lastSync = _syncStatus['lastSync'];
    final isSyncing = _syncStatus['isSyncing'] ?? false;
    final pendingItems = _syncStatus['pendingItems'] ?? 0;

    return _buildStatusCard(
      theme,
      title: 'Data Sync',
      icon: Icons.sync,
      color: isOnline ? Colors.blue : Colors.orange,
      children: [
        _buildStatusRow('Status', isOnline ? 'Online' : 'Offline'),
        _buildStatusRow('Syncing', isSyncing ? 'Yes' : 'No'),
        _buildStatusRow('Pending Items', pendingItems.toString()),
        if (lastSync != null)
          _buildStatusRow('Last Sync', _formatTimestamp(lastSync)),
      ],
    );
  }

  Widget _buildNotificationStatusCard(ThemeData theme) {
    final isInitialized = _notificationStatus['isInitialized'] ?? false;
    final settings = _notificationStatus['settings'] ?? {};
    final historyCount = _notificationStatus['historyCount'] ?? 0;

    return _buildStatusCard(
      theme,
      title: 'Notifications',
      icon: Icons.notifications,
      color: isInitialized ? Colors.green : Colors.red,
      children: [
        _buildStatusRow('Status', isInitialized ? 'Initialized' : 'Not Initialized'),
        _buildStatusRow('Quiz Reminders', settings['quiz_reminders'] == true ? 'Enabled' : 'Disabled'),
        _buildStatusRow('Achievements', settings['achievements'] == true ? 'Enabled' : 'Disabled'),
        _buildStatusRow('History Count', historyCount.toString()),
      ],
    );
  }

  Widget _buildWalletStatusCard(ThemeData theme) {
    final isInitialized = _walletStatus['isInitialized'] ?? false;
    final coins = _walletStatus['coins'] ?? 0;
    final canReceiveReward = _walletStatus['canReceiveReward'] ?? false;

    return _buildStatusCard(
      theme,
      title: 'Wallet',
      icon: Icons.account_balance_wallet,
      color: isInitialized ? Colors.green : Colors.red,
      children: [
        _buildStatusRow('Status', isInitialized ? 'Initialized' : 'Not Initialized'),
        _buildStatusRow('Coins', coins.toString()),
        _buildStatusRow('Can Receive Reward', canReceiveReward ? 'Yes' : 'No'),
      ],
    );
  }

  Widget _buildActionsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _performManualSync,
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Manual Sync'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendTestNotification,
                    icon: const Icon(Icons.notifications, size: 18),
                    label: const Text('Test Notification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Invalid timestamp';
    }
  }

  Future<void> _performManualSync() async {
    try {
      await _dataSyncService.performManualSync();
      await _loadStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manual sync completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Manual sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await _pushNotificationService.sendTestNotification();
      await _loadStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send test notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

