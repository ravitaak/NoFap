import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

/// Premium arc-ring streak display with live HH:MM:SS
class StreakDisplay extends StatefulWidget {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  const StreakDisplay({
    super.key,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  State<StreakDisplay> createState() => _StreakDisplayState();
}

class _StreakDisplayState extends State<StreakDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Arc progress: each full day = 1 full loop, within the current day show %
    final secondsInDay = 86400;
    final elapsedInCurrentDay =
        (widget.hours * 3600 + widget.minutes * 60 + widget.seconds);
    final arcProgress = elapsedInCurrentDay / secondsInDay;

    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) {
        final glow = 0.5 + 0.5 * math.sin(_glowCtrl.value * math.pi);

        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Arc ring ──
              SizedBox(
                width: 170.w,
                height: 170.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ambient glow
                    Container(
                      width: 170.w,
                      height: 170.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary
                                .withOpacity(0.10 + 0.12 * glow),
                            blurRadius: 70 + 30 * glow,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    // Backdrop glass disc
                    Container(
                      width: 155.w,
                      height: 155.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.03),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                    ),
                    // Arc painter
                    CustomPaint(
                      size: Size(155.w, 155.w),
                      painter: _ArcRingPainter(
                        progress: arcProgress,
                        glowIntensity: glow,
                      ),
                    ),
                    // Center content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tiny label
                        Text(
                          'DAY',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary.withOpacity(0.5),
                            letterSpacing: 4,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        // Big day number
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppTheme.goldGradient.createShader(b),
                          child: Text(
                            widget.days.toString(),
                            style: TextStyle(
                              fontSize: 58.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        // Streak level label
                        _StreakLevelBadge(days: widget.days),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // ── HH : MM : SS live row ──
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  color: Colors.white.withOpacity(0.04),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TimeUnit(value: widget.hours, label: 'HRS'),
                    _Colon(),
                    _TimeUnit(value: widget.minutes, label: 'MIN'),
                    _Colon(),
                    _TimeUnit(value: widget.seconds, label: 'SEC', isLive: true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Arc Ring Painter ────────────────────────────────────────────────────────

class _ArcRingPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;

  const _ArcRingPainter({
    required this.progress,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 10;
    const startAngle = -math.pi / 2;
    const strokeW = 5.0;

    // Track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..color = AppTheme.primary.withOpacity(0.10)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      0,
      math.pi * 2,
      false,
      trackPaint,
    );

    if (progress <= 0) return;

    // Glow under-layer
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + math.pi * 2 * progress,
        colors: [
          AppTheme.goldDark.withOpacity(0.3 * glowIntensity),
          AppTheme.primary.withOpacity(0.5 * glowIntensity),
          AppTheme.primaryBright.withOpacity(0.6 * glowIntensity),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      math.pi * 2 * progress,
      false,
      glowPaint,
    );

    // Main arc
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + math.pi * 2 * progress,
        colors: const [AppTheme.goldDark, AppTheme.primary, AppTheme.primaryBright],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      math.pi * 2 * progress,
      false,
      arcPaint,
    );

    // Dot at the tip of the arc
    final tipAngle = startAngle + math.pi * 2 * progress;
    final tipX = cx + radius * math.cos(tipAngle);
    final tipY = cy + radius * math.sin(tipAngle);

    canvas.drawCircle(
      Offset(tipX, tipY),
      strokeW / 2 + 2,
      Paint()
        ..color = AppTheme.primaryBright
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, 6 + 4 * glowIntensity),
    );
    canvas.drawCircle(
      Offset(tipX, tipY),
      strokeW / 2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_ArcRingPainter old) =>
      old.progress != progress || old.glowIntensity != glowIntensity;
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _StreakLevelBadge extends StatelessWidget {
  final int days;
  const _StreakLevelBadge({required this.days});

  String get _level {
    if (days >= 365) return 'REBORN';
    if (days >= 180) return 'ASCENDANT';
    if (days >= 90) return 'LEGEND';
    if (days >= 60) return 'IMMORTAL';
    if (days >= 30) return 'TITAN';
    if (days >= 14) return 'CONQUEROR';
    if (days >= 7) return 'CHAMPION';
    if (days >= 3) return 'WARRIOR';
    if (days >= 1) return 'RECRUIT';
    return 'BEGINNING';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppTheme.primary.withOpacity(0.15),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1),
      ),
      child: ShaderMask(
        shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
        child: Text(
          _level,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2.5,
          ),
        ),
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;
  final bool isLive;
  const _TimeUnit({required this.value, required this.label, this.isLive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            key: ValueKey(value),
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: isLive ? AppTheme.primaryBright : AppTheme.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
              height: 1.1,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            color: AppTheme.textMuted,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Colon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 22.sp,
          color: AppTheme.primary.withOpacity(0.4),
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}
