import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class PermanentlyStoppedScreen extends StatefulWidget {
  final Map<String, dynamic> dialogData;

  const PermanentlyStoppedScreen({super.key, required this.dialogData});

  @override
  State<PermanentlyStoppedScreen> createState() => _PermanentlyStoppedScreenState();
}

class _PermanentlyStoppedScreenState extends State<PermanentlyStoppedScreen>
    with TickerProviderStateMixin {
  late AnimationController _blobCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _blobCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack),
    );
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
    final String title = widget.dialogData['dialogTitle'] ?? 'App Unavailable';
    final String message = widget.dialogData['dialogMessage'] ??
        'This version of the app is no longer supported.\nPlease update to continue.';
    final bool isBtnEnabled = widget.dialogData['isBtnEnabled'] ?? false;
    final String btnText = widget.dialogData['dialogBtnText'] ?? 'Close App';
    final String link = widget.dialogData['link'] ?? '';
    final bool isPlayStoreLink = widget.dialogData['isPlayStoreLink'] ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Animated background ──────────────────────────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([_blobCtrl, _pulseCtrl]),
            builder: (_, __) => CustomPaint(
              painter: _StoppedBgPainter(
                blob: _blobCtrl.value,
                pulse: _pulseCtrl.value,
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Icon ──
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) => Container(
                          width: 110.w,
                          height: 110.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary.withOpacity(0.08),
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.28 + _pulseCtrl.value * 0.18),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.18 + _pulseCtrl.value * 0.12),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ShaderMask(
                            shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                            child: Icon(
                              Iconsax.warning_2,
                              size: 48.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // ── Title ──
                      ShaderMask(
                        shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      SizedBox(height: 6.h),

                      Text(
                        'NoFap Reboot: Rise & Conquer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // ── Message card ──
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.18)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.06),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondary,
                            height: 1.7,
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // ── Info badge ──
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.info_circle, size: 13.sp, color: AppTheme.primary),
                            SizedBox(width: 6.w),
                            Text(
                              'Support ended for this version',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // ── Primary action button ──
                      GestureDetector(
                        onTap: () async {
                          if (isBtnEnabled && link.isNotEmpty) {
                            final String myUrl = isPlayStoreLink
                                ? 'market://details?id=$link'
                                : link;
                            await launchUrl(Uri.parse(myUrl), mode: LaunchMode.externalApplication);
                          } else {
                            SystemNavigator.pop();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 54.h,
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.40),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isBtnEnabled ? Iconsax.arrow_up : Iconsax.close_circle,
                                size: 18.sp,
                                color: Colors.black,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                btnText,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (isBtnEnabled) ...[
                        SizedBox(height: 12.h),
                        // Secondary close button
                        GestureDetector(
                          onTap: () => SystemNavigator.pop(),
                          child: Container(
                            width: double.infinity,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(color: Colors.white.withOpacity(0.10)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Close App',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated background painter ───────────────────────────────────────────────

class _StoppedBgPainter extends CustomPainter {
  final double blob;
  final double pulse;

  const _StoppedBgPainter({required this.blob, required this.pulse});

  // App gold color
  static const _gold = Color(0xFFD4AF37);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pure black base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = Colors.black,
    );

    // Central gold glow
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.42),
      w * 0.6,
      Paint()
        ..shader = RadialGradient(colors: [
          _gold.withOpacity(0.07 + pulse * 0.04),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.42), radius: w * 0.6)),
    );

    // Soft warm amber secondary blob
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.40 + math.sin(blob * math.pi * 2) * h * 0.015),
      w * 0.28,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFF59E0B).withOpacity(0.05 + pulse * 0.03),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.40), radius: w * 0.28)),
    );

    // Concentric gold rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (int i = 1; i <= 4; i++) {
      ringPaint.color = _gold.withOpacity(0.04 + math.sin(blob * math.pi * 2 + i) * 0.02);
      canvas.drawCircle(Offset(w * 0.5, h * 0.42), w * (0.15 * i + 0.06), ringPaint);
    }

    // Floating gold dust particles
    for (int i = 0; i < 28; i++) {
      final seed = i * 0.6180;
      final x = ((seed * 7.3 + math.sin(blob * math.pi + i * 0.4) * 0.04) % 1.0) * w;
      final y = ((seed * 5.1 + blob * 0.35 + i * 0.06) % 1.0) * h;
      canvas.drawCircle(
        Offset(x, y),
        0.6 + (i % 3) * 0.4,
        Paint()..color = _gold.withOpacity(0.04 + (i % 5) * 0.012),
      );
    }

    // Bottom vignette fade
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.60, w, h * 0.40),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
        ).createShader(Rect.fromLTWH(0, h * 0.60, w, h * 0.40)),
    );
  }

  @override
  bool shouldRepaint(covariant _StoppedBgPainter old) =>
      old.blob != blob || old.pulse != pulse;
}
