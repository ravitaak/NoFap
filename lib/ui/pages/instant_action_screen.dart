import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

/// Instant Action Challenge — replaces urge energy with a physical task.
class InstantActionScreen extends StatefulWidget {
  const InstantActionScreen({super.key});

  @override
  State<InstantActionScreen> createState() => _InstantActionScreenState();
}

class _InstantActionScreenState extends State<InstantActionScreen> {
  static const _actions = [
    (emoji: '💪', title: '15 Push-Ups', desc: 'Drop and go — no excuses.', seconds: 60),
    (emoji: '💧', title: 'Drink Water', desc: 'Fill a glass. Drink it slowly.', seconds: 30),
    (emoji: '🚶', title: 'Walk 2 Minutes', desc: 'Move your body. Change location.', seconds: 120),
    (emoji: '🚿', title: 'Splash Cold Water', desc: 'Face and neck. Immediate reset.', seconds: 45),
    (emoji: '📵', title: 'Put Phone Down', desc: 'Walk away. Stay away for 5 min.', seconds: 300),
    (emoji: '🧘', title: '10 Deep Breaths', desc: 'In through nose, out through mouth.', seconds: 50),
    (emoji: '🏃', title: 'Run in Place', desc: 'High knees for 60 seconds.', seconds: 60),
    (emoji: '✍️', title: 'Journal 2 Lines', desc: 'Write how you feel. Name it.', seconds: 120),
  ];

  int? _currentIndex;
  int _secondsLeft = 0;
  bool _done = false;
  Timer? _timer;

  void _startChallenge(int i) {
    HapticFeedback.heavyImpact();
    _timer?.cancel();
    setState(() { _currentIndex = i; _secondsLeft = _actions[i].seconds; _done = false; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
        else { t.cancel(); _done = true; HapticFeedback.heavyImpact(); }
      });
    });
  }

  void _pickRandom() {
    final i = DateTime.now().millisecond % _actions.length;
    _startChallenge(i);
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

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
                      child: Icon(Icons.arrow_back_ios_new, color: AppTheme.textMuted, size: 16.sp),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🏃 INSTANT ACTION', style: TextStyle(fontSize: 10.sp, color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.w700)),
                      Text('Convert the Energy', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _pickRandom,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), gradient: AppTheme.goldGradient),
                      child: Text('Random', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _currentIndex != null ? _buildActiveChallenge() : _buildActionGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.h),
          Text('Pick your challenge', style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted)),
          Text('Convert urge energy into action.', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted.withOpacity(0.6))),
          SizedBox(height: 16.h),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h, childAspectRatio: 1.5),
              itemCount: _actions.length,
              itemBuilder: (_, i) {
                final a = _actions[i];
                return GestureDetector(
                  onTap: () => _startChallenge(i),
                  child: Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.emoji, style: TextStyle(fontSize: 22.sp)),
                        const Spacer(),
                        Text(a.title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${a.seconds}s', style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChallenge() {
    final a = _actions[_currentIndex!];
    final progress = _done ? 1.0 : 1.0 - (_secondsLeft / a.seconds);

    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          Text(a.emoji, style: TextStyle(fontSize: 56.sp)),
          SizedBox(height: 16.h),
          Text(a.title, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary), textAlign: TextAlign.center),
          SizedBox(height: 6.h),
          Text(a.desc, style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted), textAlign: TextAlign.center),
          SizedBox(height: 40.h),

          // Countdown
          SizedBox(
            width: 160.w,
            height: 160.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.07),
                  valueColor: AlwaysStoppedAnimation<Color>(_done ? AppTheme.statusSuccess : AppTheme.primary),
                  strokeCap: StrokeCap.round,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _done ? '✅' : '$_secondsLeft',
                      style: TextStyle(fontSize: _done ? 36.sp : 44.sp, fontWeight: FontWeight.w900, color: _done ? AppTheme.statusSuccess : AppTheme.textPrimary, height: 1),
                    ),
                    if (!_done) Text('seconds left', style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),

          if (_done) ...[
            ShaderMask(
              shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
              child: Text('MISSION COMPLETE', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
            ),
            SizedBox(height: 8.h),
            Text('The urge is gone. You converted it into strength.', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted), textAlign: TextAlign.center),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() { _currentIndex = null; _done = false; }),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r), border: Border.all(color: AppTheme.surfaceBorder), color: Colors.white.withOpacity(0.05)),
                      alignment: Alignment.center,
                      child: Text('Again', style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r), gradient: AppTheme.goldGradient, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 16)]),
                      alignment: Alignment.center,
                      child: Text('Done', style: TextStyle(fontSize: 13.sp, color: Colors.black, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            GestureDetector(
              onTap: () => setState(() { _timer?.cancel(); _currentIndex = null; }),
              child: Text('← Pick different challenge', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
            ),
          ],
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
