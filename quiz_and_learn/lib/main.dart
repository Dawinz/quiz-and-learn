import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/admob_service.dart';
import 'services/wallet_service.dart';
import 'services/backend_service.dart';
import 'services/push_notification_service.dart';
import 'services/data_sync_service.dart';
import 'services/config_service.dart';
import 'security/security_guard.dart';
import 'flavor_config.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_navigation_screen.dart';
import 'widgets/security_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flavor configuration first
  FlavorConfig().initialize();

  // Initialize config service
  await ConfigService().initialize();

  // Initialize security guard first
  try {
    final securityGuard = SecurityGuard();
    await securityGuard.enforceAll();
    debugPrint('Security enforcement completed');
  } catch (e) {
    debugPrint('Security enforcement failed: $e');
    // Continue with app initialization even if security fails
  }

  // Initialize AdMob service
  await AdMobService.instance.initialize();

  // Initialize wallet service
  await WalletService.instance.initialize();

  // Initialize backend services
  await BackendService().initialize();
  await PushNotificationService().initialize();
  await DataSyncService().initialize();

  runApp(const QuizAndLearnApp());
}

class QuizAndLearnApp extends StatelessWidget {
  const QuizAndLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: WalletService.instance),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: FlavorConfig().appTitle,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SecurityBanner(child: AuthWrapper()),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          // Initialize theme provider when user is authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final themeProvider =
                Provider.of<ThemeProvider>(context, listen: false);
            themeProvider
                .initialize(authProvider.userData?.id ?? 'default_user');
          });

          return const MainNavigationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
