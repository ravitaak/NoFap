import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';
import 'package:nofap_reboot/bloc/streak_cubit.dart';

class RealityCheckScreen extends StatefulWidget {
  const RealityCheckScreen({super.key});
  @override
  State<RealityCheckScreen> createState() => _RealityCheckScreenState();
}

class _RealityCheckScreenState extends State<RealityCheckScreen>
    with SingleTickerProviderStateMixin {
  bool _aggressive = false;
  int _statementIndex = 0;
  late Timer _autoScroll;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  static const _calmStatements = [
    'You will regret this in 10 minutes.',
    'This urge will pass. They always do.',
    'Your future self is watching right now.',
    'One moment of pleasure. Days of shame.',
    'You\'ve come too far to throw it away.',
    'Your streak is built moment by moment.',
    'This is not who you are becoming.',
    'Rest if you must, but do not quit.',
  ];

  static const _aggressiveStatements = [
    'DO YOU SERIOUSLY WANT TO FAIL AGAIN?!',
    'You\'ve caved before. Don\'t be that weak.',
    'Every relapse = you chose comfort over power.',
    'You\'re not tired. You\'re just scared.',
    'The version of you that fails is pathetic.',
    'Warriors don\'t quit when it gets hard.',
    'This is the exact moment champions are made.',
    'STOP. BREATHE. YOU ARE BETTER THAN THIS.',
  ];

  List<String> get _statements => _aggressive ? _aggressiveStatements : _calmStatements;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 6).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeCtrl);
    _autoScroll = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _statementIndex = (_statementIndex + 1) % _statements.length);
    });
  }

  @override
  void dispose() { _autoScroll.cancel(); _shakeCtrl.dispose(); super.dispose(); }

  void _triggerShake() {
    HapticFeedback.heavyImpact();
    _shakeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakState>(
      builder: (context, state) {
        final relapseCount = state.relapses.length;
        final currentStreak = state.currentStreakDays;

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
                      Text('🪞 REALITY CHECK', style: TextStyle(fontSize: 11.sp, color: AppTheme.statusDanger, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      // Mode toggle
                      GestureDetector(
                        onTap: () { HapticFeedback.selectionClick(); setState(() { _aggressive = !_aggressive; _statementIndex = 0; }); },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: _aggressive ? AppTheme.statusDanger.withOpacity(0.15) : AppTheme.statusSuccess.withOpacity(0.12),
                            border: Border.all(color: _aggressive ? AppTheme.statusDanger.withOpacity(0.4) : AppTheme.statusSuccess.withOpacity(0.3)),
                          ),
                          child: Text(_aggressive ? '💀 Harsh' : '😌 Calm', style: TextStyle(fontSize: 11.sp, color: _aggressive ? AppTheme.statusDanger : AppTheme.statusSuccess, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Stats row
                        Row(
                          children: [
                            Expanded(child: _StatChip(value: '$relapseCount', label: 'Past Relapses', color: AppTheme.statusDanger)),
                            SizedBox(width: 10.w),
                            Expanded(child: _StatChip(value: '$currentStreak', label: 'Days at Stake', color: AppTheme.primary)),
                          ],
                        ),
                        SizedBox(height: 32.h),

                        // Statement card
                        GestureDetector(
                          onTap: () { setState(() => _statementIndex = (_statementIndex + 1) % _statements.length); _triggerShake(); },
                          child: AnimatedBuilder(
                            animation: _shakeAnim,
                            builder: (_, child) => Transform.translate(offset: Offset(_shakeAnim.value * (_statementIndex.isEven ? 1 : -1), 0), child: child),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, anim) => FadeTransition(
                                opacity: anim,
                                child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(anim), child: child),
                              ),
                              child: Container(
                                key: ValueKey(_statementIndex),
                                width: double.infinity,
                                padding: EdgeInsets.all(28.r),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.r),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _aggressive
                                        ? [AppTheme.statusDanger.withOpacity(0.15), Colors.black]
                                        : [AppTheme.primary.withOpacity(0.10), Colors.black],
                                  ),
                                  border: Border.all(color: _aggressive ? AppTheme.statusDanger.withOpacity(0.35) : AppTheme.primary.withOpacity(0.25), width: 1.5),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _aggressive ? '⚡' : '🧭',
                                      style: TextStyle(fontSize: 40.sp),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      _statements[_statementIndex],
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w900,
                                        color: _aggressive ? AppTheme.statusDanger : AppTheme.textPrimary,
                                        height: 1.5,
                                        letterSpacing: _aggressive ? 0.5 : 0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 12.h),
                                    Text('Tap for next', style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Indicator dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_statements.length, (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            width: i == _statementIndex ? 18.w : 6.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.r),
                              color: i == _statementIndex ? AppTheme.primary : Colors.white.withOpacity(0.15),
                            ),
                          )),
                        ),

                        const Spacer(),

                        // I survived button
                        GestureDetector(
                          onTap: () { HapticFeedback.heavyImpact(); Navigator.pop(context); },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.r),
                              gradient: AppTheme.goldGradient,
                              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 24)],
                            ),
                            alignment: Alignment.center,
                            child: Text('I SURVIVED THIS URGE', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatChip({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r), color: color.withOpacity(0.08), border: Border.all(color: color.withOpacity(0.25))),
    child: Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: TextStyle(fontSize: 9.sp, color: AppTheme.textMuted), textAlign: TextAlign.center),
      ],
    ),
  );
}
