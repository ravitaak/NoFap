import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

class UrgeWaveScreen extends StatefulWidget {
  const UrgeWaveScreen({super.key});
  @override
  State<UrgeWaveScreen> createState() => _UrgeWaveScreenState();
}

class _UrgeWaveScreenState extends State<UrgeWaveScreen>
    with SingleTickerProviderStateMixin {
  // 0=intro, 1=tracking, 2=survived
  int _phase = 0;
  int _elapsedSeconds = 0;
  int? _peakSecond;
  double _currentIntensity = 0.5;
  final List<double> _intensityHistory = [];
  Timer? _timer;
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() { _timer?.cancel(); _waveCtrl.dispose(); super.dispose(); }

  void _startTracking() {
    HapticFeedback.mediumImpact();
    setState(() { _phase = 1; _elapsedSeconds = 0; _intensityHistory.clear(); _currentIntensity = 0.5; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _elapsedSeconds++;
        // Simulate natural urge curve: rises ~30s then falls
        final natural = math.exp(-math.pow((_elapsedSeconds - 30) / 25.0, 2));
        _currentIntensity = (natural * 0.8 + 0.1).clamp(0.05, 1.0);
        _intensityHistory.add(_currentIntensity);

        // Track peak
        if (_peakSecond == null && _intensityHistory.length > 5) {
          final max = _intensityHistory.reduce(math.max);
          if (_currentIntensity < max * 0.85) _peakSecond = _elapsedSeconds - 5;
        }
      });
    });
  }

  void _markUrgeGone() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() { _phase = 2; });
  }

  void _markStillFeelingIt() {
    HapticFeedback.lightImpact();
    setState(() => _currentIntensity = (_currentIntensity + 0.1).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.close, color: AppTheme.textMuted, size: 18.sp)),
                  ),
                  SizedBox(width: 14.w),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('⏳ URGE WAVE', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF38BDF8), letterSpacing: 2, fontWeight: FontWeight.w700)),
                    Text('Ride it out', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                  ]),
                ],
              ),
            ),
            Expanded(child: _buildPhase()),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case 0: return _buildIntro();
      case 1: return _buildTracking();
      case 2: return _buildSurvived();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildIntro() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Wave animation
          AnimatedBuilder(
            animation: _waveCtrl,
            builder: (_, __) {
              return CustomPaint(
                size: Size(double.infinity, 120.h),
                painter: _WavePainter(progress: _waveCtrl.value, color: const Color(0xFF38BDF8)),
              );
            },
          ),
          SizedBox(height: 32.h),
          Text('Urges are like waves.', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary), textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text('They rise, peak, and fall.\nEvery single time.\n\nThis will track your urge in real time\nand show you that you survived it.', style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted, height: 1.7), textAlign: TextAlign.center),
          SizedBox(height: 40.h),
          GestureDetector(
            onTap: _startTracking,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r), gradient: AppTheme.goldGradient, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 24)]),
              alignment: Alignment.center,
              child: Text('START TRACKING URGE', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracking() {
    final intensity = _currentIntensity;
    final intensityPct = (intensity * 100).round();
    final phase = intensity > 0.6 ? 'Rising 📈' : intensity > 0.35 ? 'Peaking ⚡' : 'Falling 📉';
    final phaseColor = intensity > 0.6 ? AppTheme.statusDanger : intensity > 0.35 ? const Color(0xFFF59E0B) : AppTheme.statusSuccess;

    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          // Timer + intensity
          Row(
            children: [
              Expanded(child: _InfoBox(value: '${_elapsedSeconds}s', label: 'Elapsed', color: const Color(0xFF38BDF8))),
              SizedBox(width: 10.w),
              Expanded(child: _InfoBox(value: '$intensityPct%', label: 'Intensity', color: phaseColor)),
              SizedBox(width: 10.w),
              Expanded(child: _InfoBox(value: phase, label: 'Phase', color: phaseColor, small: true)),
            ],
          ),
          SizedBox(height: 20.h),

          // Live wave graph
          Container(
            height: 140.h,
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r), color: Colors.white.withOpacity(0.04), border: Border.all(color: Colors.white.withOpacity(0.08))),
            child: CustomPaint(
              painter: _IntensityHistoryPainter(history: _intensityHistory, current: _elapsedSeconds),
            ),
          ),

          SizedBox(height: 24.h),
          Text('Hang on. The wave is already changing.', style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted), textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          if (_peakSecond != null)
            Text('⚡ You passed the peak at ${_peakSecond}s — it\'s falling now!', style: TextStyle(fontSize: 12.sp, color: AppTheme.statusSuccess, fontWeight: FontWeight.w700), textAlign: TextAlign.center),

          const Spacer(),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _markStillFeelingIt,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppTheme.statusDanger.withOpacity(0.4)), color: AppTheme.statusDanger.withOpacity(0.08)),
                    alignment: Alignment.center,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('😤', style: TextStyle(fontSize: 22.sp)),
                      SizedBox(height: 4.h),
                      Text('Still feeling it', style: TextStyle(fontSize: 11.sp, color: AppTheme.statusDanger, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: _markUrgeGone,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r), gradient: AppTheme.goldGradient, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 16)]),
                    alignment: Alignment.center,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('✅', style: TextStyle(fontSize: 22.sp)),
                      SizedBox(height: 4.h),
                      Text("It's gone!", style: TextStyle(fontSize: 11.sp, color: Colors.black, fontWeight: FontWeight.w900)),
                    ]),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildSurvived() {
    final peak = _peakSecond ?? (_elapsedSeconds ~/ 2);
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌊', style: TextStyle(fontSize: 64.sp)),
          SizedBox(height: 16.h),
          ShaderMask(
            shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
            child: Text('WAVE SURVIVED', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r), color: AppTheme.statusSuccess.withOpacity(0.08), border: Border.all(color: AppTheme.statusSuccess.withOpacity(0.25))),
            child: Column(children: [
              Text('Your urge peaked at ${peak}s and fell.', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary), textAlign: TextAlign.center),
              SizedBox(height: 8.h),
              Text('Total duration: ${_elapsedSeconds}s\n\nThis proves every urge is temporary.\nThe next one will be easier to beat.', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted, height: 1.7), textAlign: TextAlign.center),
            ]),
          ),
          SizedBox(height: 32.h),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r), gradient: AppTheme.goldGradient, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 24)]),
              alignment: Alignment.center,
              child: Text('I AM THE WAVE RIDER', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String value, label;
  final Color color;
  final bool small;
  const _InfoBox({required this.value, required this.label, required this.color, this.small = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: color.withOpacity(0.08), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: small ? 11.sp : 18.sp, fontWeight: FontWeight.w900, color: color), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      Text(label, style: TextStyle(fontSize: 8.sp, color: AppTheme.textMuted), textAlign: TextAlign.center),
    ]),
  );
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  const _WavePainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    final path = Path();
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + math.sin((x / size.width * 4 * math.pi) + progress * 2 * math.pi) * (size.height / 3);
      if (x == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
    final fillPaint = Paint()..color = color.withOpacity(0.07)..style = PaintingStyle.fill;
    final fillPath = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(fillPath, fillPaint);
  }
  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

class _IntensityHistoryPainter extends CustomPainter {
  final List<double> history;
  final int current;
  const _IntensityHistoryPainter({required this.history, required this.current});
  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;
    final paint = Paint()..strokeWidth = 2.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final path = Path();
    for (int i = 0; i < history.length; i++) {
      final x = (i / math.max(history.length - 1, 1)) * size.width;
      final y = size.height - history[i] * size.height;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    // Color gradient based on intensity
    paint.color = history.last > 0.6 ? AppTheme.statusDanger : history.last > 0.35 ? const Color(0xFFF59E0B) : AppTheme.statusSuccess;
    canvas.drawPath(path, paint);
    // Fill
    final fill = Paint()..style = PaintingStyle.fill..color = paint.color.withOpacity(0.1);
    final fp = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(fp, fill);
  }
  @override
  bool shouldRepaint(_IntensityHistoryPainter old) => old.history.length != history.length;
}
