import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

/// Thought Interruption — breaks mental urge loop via pattern interruption.
class ThoughtInterruptScreen extends StatefulWidget {
  const ThoughtInterruptScreen({super.key});

  @override
  State<ThoughtInterruptScreen> createState() => _ThoughtInterruptScreenState();
}

class _ThoughtInterruptScreenState extends State<ThoughtInterruptScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0; // 0=trigger, 1=breath timer, 2=tap challenge, 3=hold challenge, 4=survived
  int? _triggerIndex;
  int _tapCount = 0;
  bool _holdComplete = false;
  Timer? _holdTimer;
  int _holdSeconds = 0;
  late AnimationController _pulseCtrl;

  static const _triggers = ['Boredom', 'Loneliness', 'Stress', 'Social Media', 'Night time', 'Other'];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startHold() {
    _holdTimer?.cancel();
    _holdSeconds = 0;
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _holdSeconds++;
        if (_holdSeconds >= 30) {
          t.cancel();
          _holdComplete = true;
          HapticFeedback.heavyImpact();
        }
      });
    });
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
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(12.r)),
                      child: Icon(Icons.close, color: AppTheme.textMuted, size: 18.sp),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Text('🧠 PATTERN BREAKER', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF818CF8), letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  // Step progress
                  Row(children: List.generate(4, (i) => Container(
                    margin: EdgeInsets.only(left: 4.w),
                    width: 24.w, height: 3.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.r),
                      color: i < _step ? const Color(0xFF818CF8) : Colors.white.withOpacity(0.12),
                    ),
                  ))),
                ],
              ),
            ),
            Expanded(child: _buildStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _TriggerStep(triggers: _triggers, onSelect: (i) { HapticFeedback.mediumImpact(); setState(() { _triggerIndex = i; _step = 1; }); });
      case 1: return _BreathStep(onDone: () => setState(() => _step = 2));
      case 2: return _TapStep(tapCount: _tapCount, onTap: () { HapticFeedback.lightImpact(); setState(() { _tapCount++; if (_tapCount >= 10) _step = 3; }); });
      case 3: return _HoldStep(pulse: _pulseCtrl, seconds: _holdSeconds, complete: _holdComplete, onStart: _startHold, onDone: () => setState(() => _step = 4));
      case 4: return _SurvivedStep(trigger: _triggerIndex != null ? _triggers[_triggerIndex!] : 'Unknown', onClose: () => Navigator.pop(context));
      default: return const SizedBox.shrink();
    }
  }
}

class _TriggerStep extends StatelessWidget {
  final List<String> triggers;
  final void Function(int) onSelect;
  const _TriggerStep({required this.triggers, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 32.h),
          Text('What triggered this?', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary), textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text('Naming it breaks its power.', style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted), textAlign: TextAlign.center),
          SizedBox(height: 36.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h, childAspectRatio: 2.8),
              itemCount: triggers.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(triggers[i], style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreathStep extends StatefulWidget {
  final VoidCallback onDone;
  const _BreathStep({required this.onDone});
  @override
  State<_BreathStep> createState() => _BreathStepState();
}

class _BreathStepState extends State<_BreathStep> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _phase = 0; // 0=inhale, 1=hold, 2=exhale
  int _cycles = 0;
  static const _labels = ['Inhale...', 'Hold...', 'Exhale...'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..forward().whenComplete(_next);
  }

  void _next() {
    if (!mounted) return;
    setState(() { _phase = (_phase + 1) % 3; if (_phase == 0) _cycles++; });
    if (_cycles >= 3) { widget.onDone(); return; }
    _ctrl.reset();
    _ctrl.forward().whenComplete(_next);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('This urge will pass.', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          Text('Urges peak in 90 seconds.', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
          SizedBox(height: 40.h),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final scale = _phase == 0 ? 0.6 + 0.4 * _ctrl.value : _phase == 2 ? 1.0 - 0.4 * _ctrl.value : 1.0;
              return Transform.scale(
                scale: scale.clamp(0.6, 1.0),
                child: Container(
                  width: 160.w, height: 160.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [const Color(0xFF818CF8).withOpacity(0.5), const Color(0xFF818CF8).withOpacity(0.1), Colors.transparent]),
                  ),
                  child: Center(
                    child: Container(
                      width: 80.w, height: 80.w,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF818CF8).withOpacity(0.3), border: Border.all(color: const Color(0xFF818CF8), width: 2)),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          Text(_labels[_phase], style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: const Color(0xFF818CF8))),
          SizedBox(height: 8.h),
          Text('Cycle ${_cycles + 1} of 3', style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _TapStep extends StatelessWidget {
  final int tapCount;
  final VoidCallback onTap;
  const _TapStep({required this.tapCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('TAP FAST', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: 2)),
          SizedBox(height: 8.h),
          Text('Tap the button 10 times — breaks the mental loop!', style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted), textAlign: TextAlign.center),
          SizedBox(height: 48.h),
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: tapCount / 10,
                strokeWidth: 6,
                backgroundColor: Colors.white.withOpacity(0.07),
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 130.w, height: 130.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.goldGradient,
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 24)],
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$tapCount', style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.w900, color: Colors.black, height: 1)),
                      Text('/ 10', style: TextStyle(fontSize: 12.sp, color: Colors.black.withOpacity(0.7))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Text('⚡ Each tap breaks the loop', style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _HoldStep extends StatelessWidget {
  final AnimationController pulse;
  final int seconds;
  final bool complete;
  final VoidCallback onStart;
  final VoidCallback onDone;
  const _HoldStep({required this.pulse, required this.seconds, required this.complete, required this.onStart, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(complete ? '🔥 URGE CRUSHED!' : 'HOLD', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: complete ? AppTheme.statusSuccess : AppTheme.textPrimary, letterSpacing: 2)),
          SizedBox(height: 8.h),
          if (!complete) Text('Hold the button for 30 seconds', style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted), textAlign: TextAlign.center),
          SizedBox(height: 36.h),
          if (!complete) ...[
            GestureDetector(
              onTapDown: (_) => onStart(),
              child: AnimatedBuilder(
                animation: pulse,
                builder: (_, __) => Transform.scale(
                  scale: 1.0 + 0.05 * pulse.value,
                  child: Container(
                    width: 140.w, height: 140.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withOpacity(0.4 + 0.4 * pulse.value), width: 2),
                      color: AppTheme.primary.withOpacity(0.1 + 0.05 * pulse.value),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$seconds', style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w900, color: AppTheme.primary, height: 1)),
                        Text('seconds', style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(value: seconds / 30, minHeight: 6.h, backgroundColor: Colors.white.withOpacity(0.07), valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)),
            ),
          ] else ...[
            Icon(Icons.emoji_events, color: AppTheme.primary, size: 64.sp),
            SizedBox(height: 16.h),
            Text('You held on for 30 seconds.\nThe urge has passed.', style: TextStyle(fontSize: 15.sp, color: AppTheme.textSecondary, height: 1.6), textAlign: TextAlign.center),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: onDone,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r), gradient: AppTheme.goldGradient, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20)]),
                child: Text('WARRIOR VICTORY', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SurvivedStep extends StatelessWidget {
  final String trigger;
  final VoidCallback onClose;
  const _SurvivedStep({required this.trigger, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('👑', style: TextStyle(fontSize: 64.sp)),
          SizedBox(height: 16.h),
          Text('PATTERN BROKEN', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: 2)),
          SizedBox(height: 8.h),
          Text('You identified "$trigger" as your trigger.\nYou faced it and won.', style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary, height: 1.6), textAlign: TextAlign.center),
          SizedBox(height: 40.h),
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 16.h),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r), gradient: AppTheme.goldGradient, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 24)]),
              child: Text('BACK TO WINNING', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}
