import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  static const _durations = [5, 10, 20, 30];

  int _selectedMin = 5;
  bool _running = false;
  bool _finished = false;
  int _remaining = 5 * 60;
  int _totalSessions = 0;

  Timer? _timer;
  late AnimationController _pulseCtrl;
  late AnimationController _ringCtrl;

  @override
  void initState() {
    super.initState();
    _remaining = _selectedMin * 60;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _ringCtrl = AnimationController(
      vsync: this,
      duration: Duration(minutes: _selectedMin),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  void _start() {
    HapticFeedback.mediumImpact();
    _ringCtrl.duration = Duration(minutes: _selectedMin);
    _ringCtrl.forward(from: 0);
    setState(() {
      _running = true;
      _finished = false;
      _remaining = _selectedMin * 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_remaining > 0) {
          _remaining--;
        } else {
          t.cancel();
          _running = false;
          _finished = true;
          _totalSessions++;
          HapticFeedback.heavyImpact();
        }
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    _ringCtrl.stop();
    setState(() {
      _running = false;
      _remaining = _selectedMin * 60;
    });
  }

  void _selectDuration(int min) {
    if (_running) return;
    setState(() {
      _selectedMin = min;
      _remaining = min * 60;
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    const Color(0xFF818CF8)
                        .withOpacity(0.04 + 0.04 * _pulseCtrl.value),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _stop();
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 20.sp, color: AppTheme.primary),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (b) =>
                                AppTheme.goldGradient.createShader(b),
                            child: Text(
                              'Meditation',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            '$_totalSessions sessions completed',
                            style: TextStyle(
                                fontSize: 10.sp, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(width: 20.sp),
                    ],
                  ),
                ),

                // Duration picker
                if (!_running && !_finished) ...[
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _durations.map((min) {
                      final sel = min == _selectedMin;
                      return GestureDetector(
                        onTap: () => _selectDuration(min),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 18.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            gradient: sel ? AppTheme.goldGradient : null,
                            color: sel ? null : Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: sel
                                  ? Colors.transparent
                                  : AppTheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            '${min}m',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: sel ? Colors.black : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const Spacer(),

                if (_finished)
                  _FinishedView(onRestart: () {
                    setState(() => _finished = false);
                  })
                else ...[
                  // Timer ring + orb
                  SizedBox(
                    width: 240.w,
                    height: 240.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress ring
                        if (_running)
                          AnimatedBuilder(
                            animation: _ringCtrl,
                            builder: (_, __) => CustomPaint(
                              size: Size(240.w, 240.w),
                              painter: _MeditationRingPainter(
                                  progress: _ringCtrl.value),
                            ),
                          )
                        else
                          Container(
                            width: 240.w,
                            height: 240.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primary.withOpacity(0.12),
                                width: 3,
                              ),
                            ),
                          ),

                        // Breathing orb
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) {
                            final scale = _running
                                ? 0.7 + 0.3 * math.sin(_pulseCtrl.value * math.pi)
                                : 0.85;
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 160.w,
                                height: 160.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF818CF8).withOpacity(0.5),
                                      const Color(0xFF818CF8).withOpacity(0.15),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(_remaining),
                                        style: TextStyle(
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures()
                                          ],
                                          height: 1,
                                        ),
                                      ),
                                      Text(
                                        _running ? 'breathe...' : '${_selectedMin} min',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: const Color(0xFF818CF8),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Start / Stop
                  GestureDetector(
                    onTap: _running ? _stop : _start,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: EdgeInsets.symmetric(
                          horizontal: 48.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        gradient: _running
                            ? const LinearGradient(
                                colors: [Color(0xFF374151), Color(0xFF1F2937)])
                            : AppTheme.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: (_running
                                    ? Colors.white
                                    : AppTheme.primary)
                                .withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        _running ? 'STOP SESSION' : 'BEGIN MEDITATION',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: _running ? AppTheme.textSecondary : Colors.black,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Guide text
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    _running
                        ? 'Focus on your breath.\nLet thoughts pass like clouds.'
                        : 'Silence the mind.\nMastery begins in stillness.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textMuted,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeditationRingPainter extends CustomPainter {
  final double progress;
  _MeditationRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 6;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      0, math.pi * 2, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppTheme.primary.withOpacity(0.08),
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + math.pi * 2 * progress,
          colors: const [Color(0xFF818CF8), Color(0xFF6366F1)],
        ).createShader(Rect.fromCircle(
          center: Offset(cx, cy),
          radius: radius,
        ))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  @override
  bool shouldRepaint(_MeditationRingPainter old) => old.progress != progress;
}

class _FinishedView extends StatelessWidget {
  final VoidCallback onRestart;
  const _FinishedView({required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
          child: Icon(Icons.self_improvement, size: 80.sp, color: Colors.white),
        ),
        SizedBox(height: 20.h),
        Text(
          'Session Complete',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Mind clear. Body strong. 🧘',
          style: TextStyle(fontSize: 14.sp, color: AppTheme.statusSuccess),
        ),
        SizedBox(height: 32.h),
        GestureDetector(
          onTap: onRestart,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: AppTheme.goldGradient,
            ),
            child: Text(
              'Meditate Again',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
