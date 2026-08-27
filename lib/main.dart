// ===== IMPORTS - START =====
import 'package:flutter/material.dart';
import 'package:cpsumotorpooldriverapp/pages/loginpage.dart';
import 'package:cpsumotorpooldriverapp/pages/dashboard.dart';
import 'package:cpsumotorpooldriverapp/pages/Addtrip.dart';
import 'package:cpsumotorpooldriverapp/pages/Mytrip.dart';
import 'package:cpsumotorpooldriverapp/pages/Notifications.dart';
import 'package:cpsumotorpooldriverapp/pages/History.dart';
import 'package:cpsumotorpooldriverapp/pages/ScheduledTrip.dart';
import 'package:cpsumotorpooldriverapp/pages/splash_screen.dart';
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
            const AddTrip(), // ADD TRIP - Create new trip ticket
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
            const Placeholder(), // TODO: Create Settings page - App settings
      },
      // ===== APP ROUTING - END =====
    );
  }
}

// ===== MYAPP CLASS - END ====="
