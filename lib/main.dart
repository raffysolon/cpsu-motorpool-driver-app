// ===== IMPORTS - START =====
import 'package:flutter/material.dart';
import 'package:cpsumotorpooldriverapp/theme/app_theme.dart';
import 'package:cpsumotorpooldriverapp/pages/loginpage.dart';
import 'package:cpsumotorpooldriverapp/pages/splash_screen.dart';
import 'package:cpsumotorpooldriverapp/pages/dashboard.dart';
import 'package:cpsumotorpooldriverapp/pages/Mytrip.dart';
import 'package:cpsumotorpooldriverapp/pages/Notifications.dart';
import 'package:cpsumotorpooldriverapp/pages/History.dart';
import 'package:cpsumotorpooldriverapp/pages/ScheduledTrip.dart';
import 'package:cpsumotorpooldriverapp/pages/create_trip_ticket.dart';
import 'package:cpsumotorpooldriverapp/pages/settings.dart';
import 'package:cpsumotorpooldriverapp/widgets/app_notification.dart';

// ===== IMPORTS - END =====

// ===== MAIN ENTRY POINT - START =====
/// Main entry point of the CPSU Motorpool Driver App
void main() {
  runApp(const MyApp());
}
// ===== MAIN ENTRY POINT - END =====

// ===== MYAPP CLASS - START =====
/// Root widget that configures the entire application
/// Handles theme setup, app configuration, and routing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Builds the MaterialApp widget with theme and routes configuration
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ===== APP CONFIGURATION - START =====
      title: 'CPSU Motorpool Driver App',
      debugShowCheckedModeBanner: false,
      // ===== THEME SETUP - START =====
      /// Theme configuration: Green color scheme, light background
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: AppTypography.body,
        textTheme: AppTypography.textTheme(ThemeData.light().textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: _filledButtonStyle(),
        ),
        filledButtonTheme: FilledButtonThemeData(style: _filledButtonStyle()),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: _outlinedButtonStyle(),
        ),
        textButtonTheme: TextButtonThemeData(style: _textButtonStyle()),
      ),
      builder: (context, child) =>
          AppNotification.host(child: child ?? const SizedBox.shrink()),
      // ===== THEME SETUP - END =====
      // ===== APP ROUTING - START =====
      /// Show the branded loading screen before opening login.
      initialRoute: '/splash',

      /// Define all navigation routes for the application
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) =>
            const LoginPage(), // LOGIN PAGE - User authentication
        '/dashboard': (context) =>
            const DriverDashboard(), // DASHBOARD - Main home screen
        '/create-trip': (context) =>
            const CreateTripTicket(), // ADD TRIP - Create new trip ticket
        '/my-trips': (context) =>
            const MyTrip(), // MY TRIPS - View current trips
        '/history': (context) =>
            const HistoryPage(), // HISTORY - Past trips records
        '/scheduled-trips': (context) =>
            const ScheduledTripsPage(), // SCHEDULED TRIPS - Upcoming trips
        '/notifications': (context) =>
            const Notifications(), // NOTIFICATIONS - App notifications
        '/profile': (context) =>
            const Placeholder(), // TODO: Create Profile page - User profile management
        '/settings': (context) =>
            const SettingsPage(), // Driver profile, password, and logout
      },
      // ===== APP ROUTING - END =====
    );
  }

  static ButtonStyle _filledButtonStyle() {
    return ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
      foregroundColor: const WidgetStatePropertyAll(Colors.white),
      overlayColor: WidgetStatePropertyAll(
        Colors.white.withValues(alpha: 0.12),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      elevation: const WidgetStatePropertyAll(0),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
    );
  }

  static ButtonStyle _outlinedButtonStyle() {
    return ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.white),
      foregroundColor: const WidgetStatePropertyAll(AppColors.navy),
      overlayColor: WidgetStatePropertyAll(
        AppColors.primary.withValues(alpha: 0.08),
      ),
      side: const WidgetStatePropertyAll(
        BorderSide(color: Color(0xFF86EFAC)),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
    );
  }

  static ButtonStyle _textButtonStyle() {
    return ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(AppColors.primaryDark),
      overlayColor: WidgetStatePropertyAll(
        AppColors.primary.withValues(alpha: 0.08),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

// ===== MYAPP CLASS - END ====="
