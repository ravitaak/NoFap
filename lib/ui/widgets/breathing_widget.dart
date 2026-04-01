import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';
import 'package:nofap_reboot/bloc/urge_cubit.dart';

class BreathingWidget extends StatefulWidget {
  const BreathingWidget({super.key});

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _phaseLabel(BreathPhase phase) {
    switch (phase) {
      case BreathPhase.inhale:
        return 'INHALE';
      case BreathPhase.hold:
        return 'HOLD';
      case BreathPhase.exhale:
        return 'EXHALE';
    }
  }

  Color _phaseColor(BreathPhase phase) {
    switch (phase) {
      case BreathPhase.inhale:
        return AppTheme.primary;
      case BreathPhase.hold:
        return AppTheme.primaryBright;
      case BreathPhase.exhale:
        return AppTheme.primaryDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UrgeCubit, UrgeState>(
      builder: (context, state) {
        final label = _phaseLabel(state.breathPhase);
        final color = _phaseColor(state.breathPhase);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scale,
              builder: (_, __) {
                return SizedBox(
                  width: 200.w,
                  height: 200.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow
                      Transform.scale(
                        scale: _scale.value,
                        child: Container(
                          width: 190.w,
                          height: 190.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.15),
                                blurRadius: 50,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Ring 1
                      Transform.scale(
                        scale: _scale.value,
                        child: Container(
                          width: 160.w,
                          height: 160.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color.withOpacity(0.20),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      // Ring 2 (main)
                      Transform.scale(
                        scale: _scale.value * 0.85,
                        child: Container(
                          width: 140.w,
                          height: 140.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.08),
                            border: Border.all(
                              color: color.withOpacity(0.45),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Center dot
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                label,
                key: ValueKey(label),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 4,
                  fontFamily: 'Delius',
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '4 seconds each phase',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppTheme.textMuted,
                fontFamily: 'Delius',
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Circular countdown timer painter
class UrgeTimerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;

  const UrgeTimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Glow arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color.withOpacity(0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(covariant UrgeTimerPainter old) =>
      old.progress != progress || old.color != color;
}
