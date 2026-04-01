import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';
import 'package:nofap_reboot/bloc/urge_cubit.dart';
import 'package:nofap_reboot/ui/widgets/breathing_widget.dart';
import 'package:nofap_reboot/ui/widgets/gold_glow_container.dart';

class ShieldTab extends StatelessWidget {
  const ShieldTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UrgeCubit, UrgeState>(
      builder: (context, state) {
        final isEmergency = state.timerStatus == UrgeTimerStatus.running ||
            state.breathingActive;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Background dim when emergency mode
              if (isEmergency)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),

              // Gold accent orb
              Positioned(
                top: 40,
                right: -80,
                child: Container(
                  width: 250.w,
                  height: 250.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Header ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shield',
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                                fontFamily: 'Delius',
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (b) =>
                                  AppTheme.goldGradient.createShader(b),
                              child: Text(
                                isEmergency
                                    ? 'FOCUS MODE — STAY STRONG'
                                    : 'EMERGENCY ANTI-URGE TOOLS',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  fontFamily: 'Delius',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 28.h)),

                    // ── Urge Timer ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'URGE TIMER'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _UrgeTimerCard(),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Breathing ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'BREATHING'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: GoldGlowContainer(
                          padding: EdgeInsets.symmetric(vertical: 28.h),
                          child: Column(
                            children: [
                              const BreathingWidget(),
                              SizedBox(height: 20.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!state.breathingActive)
                                    _GoldButton(
                                      label: 'Start Breathing',
                                      icon: Icons.air,
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        context
                                            .read<UrgeCubit>()
                                            .startBreathing();
                                      },
                                    )
                                  else
                                    _GhostButton(
                                      label: 'Stop',
                                      onTap: () {
                                        context
                                            .read<UrgeCubit>()
                                            .stopBreathing();
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Distract Me ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'DISTRACT ME'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: const [
                            _DistractChip(
                              icon: Icons.fitness_center,
                              label: 'Do 20 Pushups',
                            ),
                            _DistractChip(
                              icon: Icons.directions_walk,
                              label: 'Take a Walk',
                            ),
                            _DistractChip(
                              icon: Icons.water_drop,
                              label: 'Drink Water',
                            ),
                            _DistractChip(
                              icon: Icons.shower,
                              label: 'Cold Shower',
                            ),
                            _DistractChip(
                              icon: Icons.self_improvement,
                              label: 'Meditate 5 min',
                            ),
                            _DistractChip(
                              icon: Icons.menu_book,
                              label: 'Read a Book',
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Emergency Quote ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: GoldGlowContainer(
                          padding: EdgeInsets.all(20.r),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primary.withOpacity(0.10),
                              AppTheme.surfaceBase,
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bolt,
                                color: AppTheme.primary,
                                size: 28.sp,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                '"The urge will pass. It always does.\nThe kingdom you build is permanent."',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppTheme.textPrimary,
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                  fontFamily: 'Delius',
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'REMEMBER YOUR WHY',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.5,
                                  fontFamily: 'Delius',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 100.h)),
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

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 16.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryBright, AppTheme.goldDark],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
            letterSpacing: 2.5,
            fontFamily: 'Delius',
          ),
        ),
      ],
    );
  }
}

class _UrgeTimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UrgeCubit, UrgeState>(
      builder: (context, state) {
        final isDone = state.timerStatus == UrgeTimerStatus.done;
        final isRunning = state.timerStatus == UrgeTimerStatus.running;
        final remaining = state.remainingSeconds;
        final progress = state.timerProgress;

        return GoldGlowContainer(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              // Timer circle
              SizedBox(
                width: 140.w,
                height: 140.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(140.w, 140.w),
                      painter: UrgeTimerPainter(
                        progress: isRunning || isDone ? progress : 1.0,
                        color: isDone
                            ? AppTheme.statusSuccess
                            : AppTheme.primary,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDone)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.statusSuccess,
                            size: 36.sp,
                          )
                        else ...[
                          Text(
                            isRunning ? '$remaining' : '—',
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              fontFamily: 'Delius',
                            ),
                          ),
                          if (isRunning)
                            Text(
                              'sec',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppTheme.textMuted,
                                fontFamily: 'Delius',
                              ),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              if (isDone)
                Text(
                  'You survived the urge! 🔥',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.statusSuccess,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Delius',
                  ),
                  textAlign: TextAlign.center,
                )
              else if (!isRunning)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimerSelectBtn(
                      label: '30 sec',
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        context.read<UrgeCubit>().startTimer(30);
                      },
                    ),
                    SizedBox(width: 12.w),
                    _TimerSelectBtn(
                      label: '60 sec',
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        context.read<UrgeCubit>().startTimer(60);
                      },
                    ),
                  ],
                )
              else
                _GhostButton(
                  label: 'Cancel',
                  onTap: () => context.read<UrgeCubit>().resetTimer(),
                ),

              if (isDone) ...[
                SizedBox(height: 12.h),
                _GhostButton(
                  label: 'Reset',
                  onTap: () => context.read<UrgeCubit>().resetTimer(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TimerSelectBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TimerSelectBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: AppTheme.goldGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontFamily: 'Delius',
          ),
        ),
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GoldButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 13.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: AppTheme.goldGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: Colors.black),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: 'Delius',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 11.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppTheme.surfaceBorder),
          color: AppTheme.surfaceBase,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
            fontFamily: 'Delius',
          ),
        ),
      ),
    );
  }
}

class _DistractChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DistractChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppTheme.surfaceElevated,
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.20),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15.sp, color: AppTheme.primary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
                fontFamily: 'Delius',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
