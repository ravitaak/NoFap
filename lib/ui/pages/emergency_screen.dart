import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with TickerProviderStateMixin {
  late AnimationController _breatheCtrl;
  late AnimationController _timerCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _victoryCtrl;

  int _seconds = 90;
  Timer? _countdownTimer;
  bool _survived = false;
  int _breathPhase = 0; // 0=inhale 1=hold 2=exhale 3=hold

  static const _breatheDurations = [4, 4, 4, 4];

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _timerCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 90));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _victoryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _startBreathing();
    _startCountdown();
  }

  void _startBreathing() {
    final dur = _breatheDurations[_breathPhase];
    _breatheCtrl.duration = Duration(seconds: dur);
    _breatheCtrl.reset();
    _breatheCtrl.forward().then((_) {
      if (!mounted) return;
      setState(() => _breathPhase = (_breathPhase + 1) % 4);
      _startBreathing();
    });
  }

  void _startCountdown() {
    _timerCtrl.forward();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          t.cancel();
          _survived = true;
          HapticFeedback.heavyImpact();
          _victoryCtrl.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _timerCtrl.dispose();
    _pulseCtrl.dispose();
    _victoryCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _coldShowerPrompt() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (_) => _ColdShowerSheet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Animated background ──
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) {
              final pulse = _pulseCtrl.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 1.4,
                    colors: [
                      (_survived ? AppTheme.statusSuccess : const Color(0xFFEF4444)).withOpacity(_survived ? 0.10 : 0.07 + 0.04 * pulse),
                      Colors.black,
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Content ──
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: Tween(begin: 0.95, end: 1.0).animate(anim), child: child),
              ),
              child: _survived
                  ? _SurvivedView(key: const ValueKey('survived'), victoryCtrl: _victoryCtrl, onClose: () => Navigator.pop(context))
                  : _ActiveView(
                      key: const ValueKey('active'),
                      seconds: _seconds,
                      breathPhase: _breathPhase,
                      breatheCtrl: _breatheCtrl,
                      timerCtrl: _timerCtrl,
                      pulseCtrl: _pulseCtrl,
                      onClose: () => Navigator.pop(context),
                      onColdShower: _coldShowerPrompt,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active Mode ──────────────────────────────────────────────────────────────

class _ActiveView extends StatelessWidget {
  final int seconds;
  final int breathPhase;
  final AnimationController breatheCtrl;
  final AnimationController timerCtrl;
  final AnimationController pulseCtrl;
  final VoidCallback onClose;
  final VoidCallback onColdShower;

  static const _breatheLabels = ['INHALE', 'HOLD', 'EXHALE', 'HOLD'];
  static const _breatheSubtitles = ['Breathe in slowly…', 'Hold steady…', 'Release fully…', 'Stay calm…'];
  static const _phaseColors = [Color(0xFF38BDF8), Color(0xFFD4AF37), Color(0xFF34D399), Color(0xFFD4AF37)];

  const _ActiveView({
    super.key,
    required this.seconds,
    required this.breathPhase,
    required this.breatheCtrl,
    required this.timerCtrl,
    required this.pulseCtrl,
    required this.onClose,
    required this.onColdShower,
  });

  @override
  Widget build(BuildContext context) {
    final phaseColor = _phaseColors[breathPhase];
    final timeRatio = seconds / 90.0;
    final dangerColor = timeRatio > 0.5
        ? AppTheme.statusDanger
        : timeRatio > 0.25
        ? const Color(0xFFF59E0B)
        : AppTheme.statusSuccess;

    return Column(
      children: [
        // ── Top bar ──────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    color: Colors.white.withOpacity(0.04),
                  ),
                  child: Icon(Icons.close, color: AppTheme.textMuted, size: 16.sp),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: AppTheme.statusDanger.withOpacity(0.12),
                  border: Border.all(color: AppTheme.statusDanger.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: pulseCtrl,
                      builder: (_, __) => Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.statusDanger.withOpacity(0.5 + 0.5 * pulseCtrl.value)),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'EMERGENCY',
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppTheme.statusDanger, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(width: 38.w),
            ],
          ),
        ),

        // ── Headline ──────────────────────────────────
        Text(
          'Hold On. You\'re Stronger.',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        SizedBox(height: 4.h),
        Text(
          'Urges always peak then fade.',
          style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
        ),

        SizedBox(height: 24.h),

        // ── Countdown ring ──────────────────────────────────
        SizedBox(
          width: 160.w,
          height: 160.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow ring
              AnimatedBuilder(
                animation: pulseCtrl,
                builder: (_, __) => Container(
                  width: 160.w,
                  height: 160.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: dangerColor.withOpacity(0.18 + 0.10 * pulseCtrl.value), blurRadius: 40, spreadRadius: 4)],
                  ),
                ),
              ),
              // Track
              Container(
                width: 160.w,
                height: 160.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(color: Colors.white.withOpacity(0.06), width: 2),
                ),
              ),
              // Progress arc
              AnimatedBuilder(
                animation: timerCtrl,
                builder: (_, __) => CustomPaint(
                  size: Size(160.w, 160.w),
                  painter: _ArcPainter(progress: 1.0 - timerCtrl.value, color: dangerColor),
                ),
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$seconds',
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w900,
                      color: dangerColor,
                      height: 1.0,
                      shadows: [Shadow(color: dangerColor.withOpacity(0.5), blurRadius: 20)],
                    ),
                  ),
                  Text(
                    'seconds',
                    style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted, letterSpacing: 1),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 28.h),

        // ── Breathing orb ──────────────────────────────────
        AnimatedBuilder(
          animation: breatheCtrl,
          builder: (_, __) {
            final progress = breatheCtrl.value;
            final scale = breathPhase == 0
                ? 0.65 + 0.35 * progress
                : breathPhase == 2
                ? 1.0 - 0.35 * progress
                : breathPhase == 1
                ? 1.0
                : 0.65;

            return Column(
              children: [
                SizedBox(
                  width: 110.w,
                  height: 110.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ambient glow ring
                      Transform.scale(
                        scale: scale.clamp(0.65, 1.0) * 1.3,
                        child: Container(
                          width: 110.w,
                          height: 110.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: phaseColor.withOpacity(0.20 * scale), blurRadius: 30, spreadRadius: 8)],
                          ),
                        ),
                      ),
                      // Middle ring
                      Transform.scale(
                        scale: scale.clamp(0.65, 1.0),
                        child: Container(
                          width: 90.w,
                          height: 90.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: phaseColor.withOpacity(0.10),
                            border: Border.all(color: phaseColor.withOpacity(0.35), width: 1.5),
                          ),
                        ),
                      ),
                      // Inner core
                      Transform.scale(
                        scale: (scale * 0.6).clamp(0.4, 0.6),
                        child: Container(
                          width: 90.w,
                          height: 90.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [phaseColor.withOpacity(0.6), phaseColor.withOpacity(0.15), Colors.transparent]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(breathPhase),
                    children: [
                      Text(
                        _breatheLabels[breathPhase],
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: phaseColor, letterSpacing: 2),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _breatheSubtitles[breathPhase],
                        style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        const Spacer(),

        // ── Action buttons ──────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          child: Column(
            children: [
              // Cold shower (primary)
              GestureDetector(
                onTap: onColdShower,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    gradient: LinearGradient(colors: [const Color(0xFF0EA5E9).withOpacity(0.20), const Color(0xFF38BDF8).withOpacity(0.08)]),
                    border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.40), width: 1.2),
                    boxShadow: [BoxShadow(color: const Color(0xFF38BDF8).withOpacity(0.12), blurRadius: 16)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.water_drop_rounded, size: 18.sp, color: const Color(0xFF38BDF8)),
                      SizedBox(width: 8.w),
                      Text(
                        'Cold Shower — Reset Now',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF38BDF8), letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Survived View ─────────────────────────────────────────────────────────────

class _SurvivedView extends StatelessWidget {
  final VoidCallback onClose;
  final AnimationController victoryCtrl;
  const _SurvivedView({super.key, required this.onClose, required this.victoryCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: victoryCtrl,
      builder: (_, __) {
        final t = CurvedAnimation(parent: victoryCtrl, curve: Curves.easeOutBack).value;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy
              Transform.scale(
                scale: t.clamp(0.0, 1.0),
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withOpacity(0.10),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.30), width: 1.5),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 40, spreadRadius: 4)],
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                      child: Icon(Icons.military_tech_rounded, size: 64.sp, color: Colors.white),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 28.h),

              Transform.translate(
                offset: Offset(0, 20 * (1 - t.clamp(0.0, 1.0))),
                child: Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                        child: Text(
                          'YOU SURVIVED.',
                          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'The urge peaked and passed.\nYour discipline is your superpower.',
                        style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, height: 1.7),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          color: AppTheme.statusSuccess.withOpacity(0.08),
                          border: Border.all(color: AppTheme.statusSuccess.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department_rounded, size: 16.sp, color: AppTheme.statusSuccess),
                            SizedBox(width: 8.w),
                            Text(
                              'Streak intact. Respect.',
                              style: TextStyle(fontSize: 12.sp, color: AppTheme.statusSuccess, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 48.h),

              Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: AppTheme.goldGradient,
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.40), blurRadius: 28, offset: const Offset(0, 8))],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'BACK TO WINNING  →',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Cold Shower Bottom Sheet ──────────────────────────────────────────────────

class _ColdShowerSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        color: const Color(0xFF0D1117),
        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.25)),
        boxShadow: [BoxShadow(color: const Color(0xFF38BDF8).withOpacity(0.12), blurRadius: 32)],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.r), color: Colors.white.withOpacity(0.15)),
          ),
          SizedBox(height: 20.h),
          Text('🚿', style: TextStyle(fontSize: 48.sp)),
          SizedBox(height: 12.h),
          Text(
            'Cold Shower Protocol',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            'Cold water resets your dopamine in seconds.\n2 minutes. That\'s all it takes.\nThe urge WILL disappear.',
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary, height: 1.7),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          // Steps
          _ShowerStep(num: 1, text: 'Walk to the bathroom NOW'),
          SizedBox(height: 8.h),
          _ShowerStep(num: 2, text: 'Turn it to cold — no hesitation'),
          SizedBox(height: 8.h),
          _ShowerStep(num: 3, text: 'Stay for 2 minutes minimum'),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)]),
                boxShadow: [BoxShadow(color: const Color(0xFF38BDF8).withOpacity(0.35), blurRadius: 16)],
              ),
              alignment: Alignment.center,
              child: Text(
                'I\'M GOING NOW 🚿',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowerStep extends StatelessWidget {
  final int num;
  final String text;
  const _ShowerStep({required this.num, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF38BDF8).withOpacity(0.15),
          border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
        ),
        alignment: Alignment.center,
        child: Text(
          '$num',
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFF38BDF8)),
        ),
      ),
      SizedBox(width: 10.w),
      Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
      ),
    ],
  );
}

// ── Arc Painter ───────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 7;
    const startAngle = -math.pi / 2;
    const strokeW = 6.0;

    // Glow layer
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = color.withOpacity(0.30),
    );

    // Main arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round
        ..color = color,
    );

    // Tip dot
    final tipAngle = startAngle + math.pi * 2 * progress;
    final tipX = cx + radius * math.cos(tipAngle);
    final tipY = cy + radius * math.sin(tipAngle);
    canvas.drawCircle(
      Offset(tipX, tipY),
      strokeW / 2 + 2.5,
      Paint()
        ..color = color.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(Offset(tipX, tipY), strokeW / 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress || old.color != color;
}
