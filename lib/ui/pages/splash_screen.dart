import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nofap_reboot/constants.dart';

const _bg = Color(0xFF000000);
const _accent = Color(0xFFE8C847);
const _goldGlow = Color(0xFFD4AF37);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _blobCtrl;
  late AnimationController _pulseCtrl;

  late AnimationController _entryCtrl;
  late Animation<double> _iconScale;
  late Animation<double> _iconFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _subFade;
  late Animation<double> _barProgress;

  @override
  void initState() {
    super.initState();

    _blobCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..forward();

    _iconFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.00, 0.25, curve: Curves.easeOut),
    );
    _iconScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.00, 0.35, curve: Curves.elasticOut),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.25, 0.50, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.25, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    _subFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.40, 0.60, curve: Curves.easeOut),
    );

    _barProgress = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.35, 0.95, curve: Curves.easeInOut),
    );

    _entryCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _blobCtrl.dispose();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_blobCtrl, _pulseCtrl, _entryCtrl]),
        builder: (_, __) {
          return Stack(
            children: [
              CustomPaint(
                size: size,
                painter: _SplashBlobPainter(blob: _blobCtrl.value, pulse: _pulseCtrl.value),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _iconFade,
                      child: Transform.scale(
                        scale: _iconScale.value,
                        child: Container(
                          width: 96.w,
                          height: 96.w,
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(28.r),
                            border: Border.all(color: _accent.withOpacity(0.28), width: 1.5),
                            boxShadow: [BoxShadow(color: _accent.withOpacity(0.18 + _pulseCtrl.value * 0.12), blurRadius: 40, spreadRadius: 4)],
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.military_tech, size: 44.sp, color: _accent),
                        ),
                      ),
                    ),
                    SizedBox(height: 28.h),
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Text(
                           'NoFap Reboot',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Delius',
                            letterSpacing: -0.5,
                            shadows: [Shadow(color: _accent.withOpacity(0.35), blurRadius: 16)],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    FadeTransition(
                      opacity: _subFade,
                      child: Text(
                         'Rise. Conquer. Ascend.',
                        style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.55), fontFamily: 'Delius', letterSpacing: 1.2),
                      ),
                    ),
                    SizedBox(height: 52.h),
                    SizedBox(
                      width: 160.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: LinearProgressIndicator(
                          value: _barProgress.value,
                          minHeight: 3.h,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(_accent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 32.h + MediaQuery.of(context).padding.bottom,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _subFade,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.white.withOpacity(0.10)),
                      ),
                      child: Text(
                        'v${Constants.appVersionName}',
                        style: TextStyle(fontSize: 10.sp, color: Colors.white.withOpacity(0.40), fontFamily: 'Delius', letterSpacing: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SplashBlobPainter extends CustomPainter {
  final double blob;
  final double pulse;

  const _SplashBlobPainter({required this.blob, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000000), Color(0xFF050300), Color(0xFF000000)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5 + math.sin(blob * math.pi * 2) * w * 0.10, h * 0.35 + math.sin(blob * math.pi * 2 + 1.0) * h * 0.05),
        width: w * 0.90,
        height: h * 0.50,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [_goldGlow.withOpacity(0.20 + pulse * 0.08), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.35), radius: w * 0.45)),
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.85, h * 0.75), width: w * 0.55, height: h * 0.30),
      Paint()
        ..shader = RadialGradient(
          colors: [_accent.withOpacity(0.09 + pulse * 0.04), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(w * 0.85, h * 0.75), radius: w * 0.28)),
    );

    for (int i = 0; i < 22; i++) {
      final seed = i * 0.618;
      final x = ((seed * 6.1 + math.sin(blob * math.pi * 2 + i * 0.7) * 0.05) % 1.0) * w;
      final y = ((seed * 3.7 + blob * 0.4 + i * 0.11) % 1.0) * h;
      final r = 0.7 + (i % 4) * 0.5;
      canvas.drawCircle(Offset(x, y), r, Paint()..color = _accent.withOpacity(0.06 + (i % 5) * 0.018));
    }

    final linePaint = Paint()
      ..color = _accent.withOpacity(0.025)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 8; i++) {
      final y = (i / 7) * h;
      canvas.drawLine(Offset(0, y), Offset(w, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashBlobPainter old) => old.blob != blob || old.pulse != pulse;
}
