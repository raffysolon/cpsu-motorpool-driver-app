// ===== IMPORTS - START =====
import 'package:flutter/material.dart';
import 'package:cpsumotorpooldriverapp/pages/loginpage.dart';
import 'package:cpsumotorpooldriverapp/pages/dashboard.dart';
import 'package:cpsumotorpooldriverapp/pages/Mytrip.dart';
import 'package:cpsumotorpooldriverapp/pages/Notifications.dart';
import 'package:cpsumotorpooldriverapp/pages/History.dart';
import 'package:cpsumotorpooldriverapp/pages/ScheduledTrip.dart';
import 'package:cpsumotorpooldriverapp/pages/splash_screen.dart';
import 'package:cpsumotorpooldriverapp/pages/create_trip_ticket.dart';
import 'package:cpsumotorpooldriverapp/pages/settings.dart';

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
        colorSchemeSeed: const Color(0xFF0F8C59), // Main green color
        scaffoldBackgroundColor: const Color(0xFFF5F6F5), // Light background
        elevatedButtonTheme: ElevatedButtonThemeData(style: _buttonStyle()),
        filledButtonTheme: FilledButtonThemeData(style: _buttonStyle()),
        outlinedButtonTheme: OutlinedButtonThemeData(style: _buttonStyle()),
        textButtonTheme: TextButtonThemeData(style: _buttonStyle()),
      ),
      // ===== THEME SETUP - END =====
      // ===== APP ROUTING - START =====
      /// Initial route when app starts (Splash screen)
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

  static ButtonStyle _buttonStyle() {
    return ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.white),
      foregroundColor: const WidgetStatePropertyAll(Colors.black),
      overlayColor: WidgetStatePropertyAll(
        const Color(0xFF0F8C59).withValues(alpha: 0.10),
      ),
      side: const WidgetStatePropertyAll(BorderSide(color: Color(0xFF9FD8BD))),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      elevation: const WidgetStatePropertyAll(0),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
    );
  }
}

// ===== MYAPP CLASS - END ====="
