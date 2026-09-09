import 'package:flutter/material.dart';
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
  static const Color green = Color(0xFF0F8C59);
  static const Color softGreen = Color(0xFFBFE8D1);
  static const Color textColor = Color(0xFF1F2A2A);
  static const Color mutedColor = Color(0xFF7C7C7C);

  late final AnimationController _animationController;
  late final Animation<double> _firstDotAnimation;
  late final Animation<double> _secondDotAnimation;
  late final Animation<double> _thirdDotAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _firstDotAnimation = _dotAnimation(0.0);
    _secondDotAnimation = _dotAnimation(0.2);
    _thirdDotAnimation = _dotAnimation(0.4);
    _startAuthCheck();
  }

  Animation<double> _dotAnimation(double start) {
    final end = start + 0.4;
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeInOut),
      ),
    );
  }

  Future<void> _startAuthCheck() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }

    final isAuthenticated = await _checkAuthStatus();
    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isAuthenticated ? const DriverDashboard() : const LoginPage(),
      ),
    );
  }

  Future<bool> _checkAuthStatus() async {
    final token = await AuthService.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoadingIcon(),
              const SizedBox(height: 28),
              const Text(
                'CPSU Motorpool',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Checking your session…',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              _buildBouncingDots(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIcon() {
    return SizedBox(
      width: 124,
      height: 124,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 124,
            height: 124,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: green,
              backgroundColor: softGreen,
            ),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: softGreen,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: green,
              size: 44,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBouncingDots() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(_firstDotAnimation.value),
            const SizedBox(width: 6),
            _buildDot(_secondDotAnimation.value),
            const SizedBox(width: 6),
            _buildDot(_thirdDotAnimation.value),
          ],
        );
      },
    );
  }

  Widget _buildDot(double animationValue) {
    final offset = -5 * Curves.easeOut.transform(animationValue);
    final opacity = 0.45 + (animationValue * 0.55);
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, offset),
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: green,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
