// ===== IMPORTS - START =====
import 'package:flutter/material.dart';
import 'package:cpsumotorpooldriverapp/theme/app_theme.dart';
import 'package:cpsumotorpooldriverapp/pages/loginpage.dart';
import 'package:cpsumotorpooldriverapp/pages/forgot_password_page.dart';
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
        dividerTheme: const DividerThemeData(
          color: Color(0xFFDEE7E1),
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAF9),
          hintStyle: const TextStyle(color: Color(0xFF718078), fontSize: 14),
          labelStyle: const TextStyle(color: Color(0xFF58675F), fontSize: 14),
          floatingLabelStyle: const TextStyle(
            color: Color(0xFF176E30),
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDEE7E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1F8A3D), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB42318)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB42318), width: 1.5),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF1F8A3D),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF1F8A3D),
          selectionColor: Color(0x331F8A3D),
          selectionHandleColor: Color(0xFF1F8A3D),
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2933),
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
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
        '/forgot-password': (context) => const ForgotPasswordPage(),
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
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? const Color(0xFFE3EAE5)
            : AppColors.primary,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? const Color(0xFF718078)
            : Colors.white,
      ),
      overlayColor: WidgetStatePropertyAll(
        Colors.white.withValues(alpha: 0.12),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      side: const WidgetStatePropertyAll(BorderSide(color: Color(0xFFC7D9CC))),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
