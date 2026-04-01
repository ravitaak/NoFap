import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

/// A container with a gold border glow effect
class GoldGlowContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double glowIntensity;
  final Color? color;
  final Gradient? gradient;

  const GoldGlowContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.glowIntensity = 1.0,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20.r);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: gradient == null ? (color ?? AppTheme.surfaceBase) : null,
        gradient: gradient,
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.35 * glowIntensity),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.18 * glowIntensity),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08 * glowIntensity),
            blurRadius: 48,
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: padding ?? EdgeInsets.all(16.r),
          child: child,
        ),
      ),
    );
  }
}
