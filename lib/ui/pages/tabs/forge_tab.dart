import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';
import 'package:nofap_reboot/bloc/urge_cubit.dart';
import 'package:nofap_reboot/ui/pages/boss_fight_screen.dart';
import 'package:nofap_reboot/ui/pages/emergency_screen.dart';
import 'package:nofap_reboot/ui/pages/identity_lock_screen.dart';
import 'package:nofap_reboot/ui/pages/instant_action_screen.dart';
import 'package:nofap_reboot/ui/pages/journal_screen.dart';
import 'package:nofap_reboot/ui/pages/meditation_screen.dart';
import 'package:nofap_reboot/ui/pages/reality_check_screen.dart';
import 'package:nofap_reboot/ui/pages/trigger_stack_screen.dart';
import 'package:nofap_reboot/ui/pages/urge_heatmap_screen.dart';
import 'package:nofap_reboot/ui/pages/urge_prediction_screen.dart';
import 'package:nofap_reboot/ui/pages/urge_wave_screen.dart';
import 'package:nofap_reboot/ui/widgets/breathing_widget.dart';

// ── Daily challenges definition ─────────────────────────────────────────────

class _Challenge {
  final String id;
  final String title;
  final String emoji;
  final String description;
  _Challenge({required this.id, required this.title, required this.emoji, required this.description});
}

final _challenges = [
  _Challenge(id: 'pushups', title: 'Push-ups', emoji: '💪', description: '20+ reps'),
  _Challenge(id: 'cold', title: 'Cold Shower', emoji: '🚿', description: '2 min cold'),
  _Challenge(id: 'read', title: 'Read', emoji: '📖', description: '15 minutes'),
  _Challenge(id: 'meditate', title: 'Meditate', emoji: '🧘', description: '5 minutes'),
  _Challenge(id: 'journal', title: 'Journal', emoji: '✍️', description: 'Write thoughts'),
];

// ── Rotating affirmations ────────────────────────────────────────────────────

const _affirmations = [
  "I am in control of my mind and body.",
  "Every day clean is a victory worth celebrating.",
  "I choose discipline over instant pleasure.",
  "My willpower grows stronger with each trial I endure.",
  "I am building the man I was always meant to be.",
  "Discomfort today creates power tomorrow.",
  "I rewire my brain. I reclaim my life.",
  "My energy is sacred. I protect it fiercely.",
  "I am not my urges. I am the master of them.",
  "The pain of discipline is nothing compared to the pain of regret.",
  "I am ascending. Every second counts.",
  "I attract greatness because I commit to greatness.",
  "My best self is born through consistent daily choices.",
  "I choose to rise when others fall.",
];

// ── ForgeTab ─────────────────────────────────────────────────────────────────

class ForgeTab extends StatefulWidget {
  const ForgeTab({super.key});

  @override
  State<ForgeTab> createState() => _ForgeTabState();
}

class _ForgeTabState extends State<ForgeTab> {
  // Track completed challenge IDs for today (in-memory; persists across navigation but not app restarts)
  final Set<String> _done = {};
  late int _affirmationIndex;

  @override
  void initState() {
    super.initState();
    _affirmationIndex = DateTime.now().day % _affirmations.length;
  }

  int get _completedCount => _done.length;
  bool get _isPerfectDay => _completedCount == _challenges.length;

  void _toggle(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_done.contains(id)) {
        _done.remove(id);
      } else {
        _done.add(id);
        if (_isPerfectDay) HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient
          Positioned(
            top: -60,
            right: -80,
            child: Container(
              width: 280.w,
              height: 280.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFFEF4444).withOpacity(0.05), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: 250,
            left: -80,
            child: Container(
              width: 220.w,
              height: 220.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.primary.withOpacity(0.04), Colors.transparent]),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                // ── Header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily',
                              style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted, letterSpacing: 0.5),
                            ),
                            SizedBox(height: 2.h),
                            ShaderMask(
                              shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                              child: Text(
                                'Forge',
                                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: _isPerfectDay
                              ? _GoldBadge(key: const ValueKey('perfect'), label: '✦ PERFECT DAY')
                              : _ProgressBadge(key: const ValueKey('progress'), done: _completedCount, total: _challenges.length),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                // ── Progress Ring ──
                SliverToBoxAdapter(
                  child: Center(
                    child: _DailyProgressRing(done: _completedCount, total: _challenges.length),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                // ── Challenges ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _SectionLabel(label: 'DAILY CHALLENGES'),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 10.h),
                      child: _ChallengeCard(
                        challenge: _challenges[i],
                        isDone: _done.contains(_challenges[i].id),
                        onToggle: () => _toggle(_challenges[i].id),
                      ),
                    ),
                    childCount: _challenges.length,
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                // ── Quick Access ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _SectionLabel(label: 'QUICK ACCESS'),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: SizedBox(
                      height: 88.h,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _QuickAccessBtn(
                              icon: Icons.warning_amber_rounded,
                              label: 'Emergency\nRoom',
                              color: const Color(0xFFEF4444),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _QuickAccessBtn(
                              icon: Icons.book_outlined,
                              label: 'Journal',
                              color: AppTheme.primary,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalScreen())),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _QuickAccessBtn(
                              icon: Icons.self_improvement,
                              label: 'Meditate',
                              color: const Color(0xFF818CF8),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MeditationScreen())),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _SectionLabel(label: 'URGE SOS TOOLKIT'),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _UrgeTimerCard(),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _BreathingCard(),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                // ── Smart Arsenal ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _SectionLabel(label: 'SMART ARSENAL'),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _ArsenalCard(
                                emoji: '⚡',
                                title: 'Urge Predictor',
                                desc: 'See your risky times before they hit',
                                color: const Color(0xFFF59E0B),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UrgePredictionScreen())),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _ArsenalCard(
                                emoji: '�ð',
                                title: 'Reality Check',
                                desc: 'Harsh psychological hit when urge strikes',
                                color: AppTheme.statusDanger,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RealityCheckScreen())),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: _ArsenalCard(
                                emoji: '⏳',
                                title: 'Urge Wave',
                                desc: 'Track the wave until it passes',
                                color: const Color(0xFF38BDF8),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UrgeWaveScreen())),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _ArsenalCard(
                                emoji: '🧦',
                                title: 'Identity Lock',
                                desc: 'This doesn\'t match who you are',
                                color: AppTheme.primary,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IdentityLockScreen())),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: _ArsenalCard(
                                emoji: '🧠',
                                title: 'Trigger Stack',
                                desc: 'Detect your danger combinations',
                                color: const Color(0xFF818CF8),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TriggerStackScreen())),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _ArsenalCard(
                                emoji: '🏘️',
                                title: 'Boss Fight',
                                desc: 'Turn the urge into a 90-sec battle',
                                color: AppTheme.statusDanger,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BossFightScreen())),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: _ArsenalCard(
                                emoji: '🏃',
                                title: 'Instant Action',
                                desc: 'Convert urge energy into strength',
                                color: AppTheme.statusSuccess,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstantActionScreen())),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _ArsenalCard(
                                emoji: '🔥',
                                title: 'Urge Heatmap',
                                desc: 'See your patterns visually',
                                color: AppTheme.statusDanger,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UrgeHeatmapScreen())),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                // ── Affirmation ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _SectionLabel(label: 'POWER AFFIRMATION'),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _AffirmationCard(
                      text: _affirmations[_affirmationIndex],
                      onNext: () => setState(() {
                        _affirmationIndex = (_affirmationIndex + 1) % _affirmations.length;
                      }),
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
  }
}

// ── Challenge Card ───────────────────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  final _Challenge challenge;
  final bool isDone;
  final VoidCallback onToggle;
  const _ChallengeCard({required this.challenge, required this.isDone, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: isDone ? AppTheme.primary.withOpacity(0.10) : Colors.white.withOpacity(0.04),
          border: Border.all(color: isDone ? AppTheme.primary.withOpacity(0.40) : Colors.white.withOpacity(0.08), width: 1),
          boxShadow: isDone ? [BoxShadow(color: AppTheme.primary.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          children: [
            // Emoji circle
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(shape: BoxShape.circle, color: isDone ? AppTheme.primary.withOpacity(0.18) : Colors.white.withOpacity(0.05)),
              alignment: Alignment.center,
              child: Text(challenge.emoji, style: TextStyle(fontSize: 20.sp)),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: isDone ? AppTheme.primary : AppTheme.textPrimary),
                  ),
                  Text(
                    challenge.description,
                    style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: isDone
                  ? Icon(Icons.check_circle_rounded, key: const ValueKey('check'), color: AppTheme.primary, size: 24.sp)
                  : Container(
                      key: const ValueKey('circle'),
                      width: 24.sp,
                      height: 24.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Daily Progress Ring ──────────────────────────────────────────────────────

class _DailyProgressRing extends StatelessWidget {
  final int done;
  final int total;
  const _DailyProgressRing({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    return SizedBox(
      width: 120.w,
      height: 120.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120.w,
            height: 120.w,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(done == total ? AppTheme.statusSuccess : AppTheme.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$done/$total',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
              ),
              Text(
                'DONE',
                style: TextStyle(fontSize: 9.sp, color: AppTheme.textMuted, letterSpacing: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Urge Timer Card ──────────────────────────────────────────────────────────

class _UrgeTimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UrgeCubit, UrgeState>(
      builder: (context, state) {
        final isRunning = state.timerStatus == UrgeTimerStatus.running;
        final isDone = state.timerStatus == UrgeTimerStatus.done;
        final progress = state.timerProgress;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: Colors.white.withOpacity(0.04),
                border: Border.all(color: AppTheme.primary.withOpacity(0.18), width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: AppTheme.primary, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Urge Timer',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const Spacer(),
                      if (isRunning || isDone)
                        GestureDetector(
                          onTap: () => context.read<UrgeCubit>().resetTimer(),
                          child: Text(
                            'Reset',
                            style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (isDone)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.statusSuccess, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'You survived the urge! 🔥',
                          style: TextStyle(fontSize: 14.sp, color: AppTheme.statusSuccess, fontWeight: FontWeight.w700),
                        ),
                      ],
                    )
                  else if (isRunning)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6.h,
                            backgroundColor: Colors.white.withOpacity(0.07),
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ShaderMask(
                              shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                              child: Text(
                                '${state.remainingSeconds}',
                                style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                'sec',
                                style: TextStyle(fontSize: 16.sp, color: AppTheme.textMuted),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Hold on. This will pass.',
                          style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TimerBtn(
                          label: '30 sec',
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            context.read<UrgeCubit>().startTimer(30);
                          },
                        ),
                        SizedBox(width: 12.w),
                        _TimerBtn(
                          label: '60 sec',
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            context.read<UrgeCubit>().startTimer(60);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimerBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TimerBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: AppTheme.goldGradient,
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black),
        ),
      ),
    );
  }
}

// ── Breathing Card ───────────────────────────────────────────────────────────

class _BreathingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UrgeCubit, UrgeState>(
      builder: (context, state) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: Colors.white.withOpacity(0.04),
                border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.25), width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.air, color: const Color(0xFF818CF8), size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Breathing Exercise',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const Spacer(),
                      if (state.breathingActive)
                        GestureDetector(
                          onTap: () {
                            context.read<UrgeCubit>().stopBreathing();
                          },
                          child: Text(
                            'Stop',
                            style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  const BreathingWidget(),
                  SizedBox(height: 16.h),
                  if (!state.breathingActive)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.read<UrgeCubit>().startBreathing();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          color: const Color(0xFF818CF8).withOpacity(0.15),
                          border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.air, size: 16.sp, color: const Color(0xFF818CF8)),
                            SizedBox(width: 8.w),
                            Text(
                              'Start Breathing',
                              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF818CF8), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Affirmation Card ─────────────────────────────────────────────────────────

class _AffirmationCard extends StatefulWidget {
  final String text;
  final VoidCallback onNext;

  const _AffirmationCard({required this.text, required this.onNext});

  @override
  State<_AffirmationCard> createState() => _AffirmationCardState();
}

class _AffirmationCardState extends State<_AffirmationCard> {
  bool _revealed = false;

  @override
  void didUpdateWidget(covariant _AffirmationCard old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) _revealed = false;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(22.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary.withOpacity(0.10), Colors.white.withOpacity(0.03)],
            ),
            border: Border.all(color: AppTheme.primary.withOpacity(0.22), width: 1),
          ),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                child: Text(
                  '"',
                  style: TextStyle(fontSize: 60.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 0.6),
                ),
              ),
              SizedBox(height: 14.h),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                    child: child,
                  ),
                ),
                child: _revealed
                    ? Column(
                        key: ValueKey('revealed_${widget.text}'),
                        children: [
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppTheme.textPrimary,
                              fontStyle: FontStyle.italic,
                              height: 1.7,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          GestureDetector(
                            onTap: widget.onNext,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh, size: 14.sp, color: AppTheme.textMuted),
                                SizedBox(width: 4.w),
                                Text(
                                  'Next affirmation',
                                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : GestureDetector(
                        key: const ValueKey('hidden'),
                        onTap: () => setState(() => _revealed = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r), gradient: AppTheme.goldGradient),
                          child: Text(
                            'Reveal Affirmation',
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryBright, AppTheme.goldDark],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 2.5),
        ),
      ],
    );
  }
}

class _GoldBadge extends StatelessWidget {
  final String label;
  const _GoldBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: AppTheme.goldGradient,
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 1),
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressBadge({super.key, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppTheme.primary.withOpacity(0.10),
        border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
      ),
      child: Text(
        '$done/$total Done',
        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 0.5),
      ),
    );
  }
}

// ── Quick Access Button ───────────────────────────────────────────────────────

class _QuickAccessBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: color.withOpacity(0.10),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24.sp, color: color),
                SizedBox(height: 6.h),
                Text(
                  label,
                  style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: color, height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Arsenal Card ─────────────────────────────────────────────────────────────

class _ArsenalCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _ArsenalCard({required this.emoji, required this.title, required this.desc, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.10), Colors.white.withOpacity(0.03)],
          ),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: TextStyle(fontSize: 20.sp)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 10.sp, color: color.withOpacity(0.5)),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
            SizedBox(height: 3.h),
            Text(
              desc,
              style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
