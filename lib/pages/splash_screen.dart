import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cpsumotorpooldriverapp/theme/app_theme.dart';
import 'package:cpsumotorpooldriverapp/pages/dashboard.dart';
import 'package:cpsumotorpooldriverapp/pages/loginpage.dart';
import 'package:cpsumotorpooldriverapp/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _startAuthCheck();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  Future<void> _startAuthCheck() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final isLoggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      // User is logged in, go to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DriverDashboard()),
      );
    } else {
      // Not logged in, go to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F3D24), // Dark green
              Color(0xFF176E30),
              Color(0xFF1F8A3D),
              Color(0xFF0B2E1A),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Color(0xFF0B8F5A),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CPSU MOTORPOOL',
                        style: AppTypography.displayTitle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'VEHICLE TRACKING SYSTEM',
                        style: AppTypography.labelCaps(
                          color: const Color(0xD9FFFFFF),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 38),
              AnimatedBuilder(
                animation: _dotsController,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, _buildDot),
                  );
                },
              ),
              const SizedBox(height: 18),
              Text(
                'Verifying account access…',
                style: AppTypography.bodyStyle(
                  color: const Color(0xB3FFFFFF),
                  fontSize: 12,
                  letterSpacing: .3,
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final progress = (_dotsController.value + index * .2) % 1;
    final pulse = (math.sin(progress * math.pi * 2) + 1) / 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Opacity(
        opacity: .45 + pulse * .55,
        child: Transform.scale(
          scale: 1 + pulse * .3,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
