import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cpsumotorpooldriverapp/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotsController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _dotsController.dispose();
    super.dispose();
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
              Color(0xFF0F3D24),
              Color(0xFF176E30),
              Color(0xFF1F8A3D),
              Color(0xFF0B2E1A),
            ],
            stops: [0, 0.35, 0.7, 1],
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
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/image/cpsu logo.png',
                        fit: BoxFit.contain,
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
                  builder: (context, child) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, _buildDot),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Preparing your workspace...',
                  style: AppTypography.bodyStyle(
                    color: const Color(0xB3FFFFFF),
                    fontSize: 12,
                    letterSpacing: 0.3,
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
    final progress = (_dotsController.value + index * 0.2) % 1;
    final pulse = (math.sin(progress * math.pi * 2) + 1) / 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Opacity(
        opacity: 0.45 + pulse * 0.55,
        child: Transform.scale(
          scale: 1 + pulse * 0.3,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 7, height: 7),
          ),
        ),
      ),
    );
  }
}
