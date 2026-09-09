import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1F8A3D);
  static const Color primaryDark = Color(0xFF176E30);
  static const Color brandDeep = Color(0xFF0F3D24);
  static const Color mint = Color(0xFFB7E4C7);
  static const Color navy = Color(0xFF1F2933);
  static const Color muted = Color(0xFF94A3B8);
  static const Color mutedDark = Color(0xFF6B7280);
  static const Color background = Color(0xFFF3F8F4);
  static const Color border = Color(0xFFE2E8F0);
  static const Color glassFill = Color(0xEBFFFFFF);
  static const Color glassBorder = Color(0xB3FFFFFF);
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.borderRadius = 18,
    this.blurSigma = 18,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandDeep.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class ShellAtmosphere extends StatelessWidget {
  const ShellAtmosphere({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF3F8F4),
                Color(0xFFE8F5EC),
                Color(0xFFF8FAFC),
                Color(0xFFEAF6EE),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        ),
        Positioned(
          right: -90,
          top: -70,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          left: -110,
          bottom: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.mint.withValues(alpha: 0.18),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
