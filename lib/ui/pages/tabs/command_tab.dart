import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';
import 'package:nofap_reboot/bloc/streak_cubit.dart';
import 'package:nofap_reboot/ui/pages/emergency_screen.dart';
import 'package:nofap_reboot/ui/widgets/quote_card.dart';
import 'package:nofap_reboot/ui/widgets/streak_display.dart';

// ── Benefits unlocked at milestones ─────────────────────────────────────────

const _benefits = [
  (days: 1, icon: '⚡', text: 'Energy surging'),
  (days: 3, icon: '😴', text: 'Sleep improving'),
  (days: 7, icon: '🧠', text: 'Brain fog lifting'),
  (days: 14, icon: '💪', text: 'Testosterone rising'),
  (days: 21, icon: '🎯', text: 'Laser focus mode'),
  (days: 30, icon: '🏆', text: 'Confidence rebuilt'),
  (days: 60, icon: '🌟', text: 'Attraction amplified'),
  (days: 90, icon: '👑', text: 'Full power unlocked'),
  (days: 180, icon: '🔱', text: 'Ascendant mind'),
  (days: 365, icon: '♾️', text: 'Reborn. Unstoppable.'),
];

// ── CommandTab ───────────────────────────────────────────────────────────────

class CommandTab extends StatelessWidget {
  final VoidCallback? onUrgePressed;
  const CommandTab({super.key, this.onUrgePressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakState>(
      builder: (context, state) {
        final dur = state.currentStreakDuration;
        final days = dur.inDays;
        final hours = dur.inHours % 24;
        final minutes = dur.inMinutes % 60;
        final seconds = state.currentStreakSeconds;
        final hasStreak = state.startDate != null;

        return Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Cinematic Hero ──
              SliverToBoxAdapter(
                child: _CinematicHero(
                  days: days,
                  hours: hours,
                  minutes: minutes,
                  seconds: seconds,
                  hasStreak: hasStreak,
                  onRelapse: () => context.read<StreakCubit>().relapse(),
                  onStart: () => context.read<StreakCubit>().startStreak(),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 16.h)),

              // ── Benefits Ticker ──
              SliverToBoxAdapter(child: _BenefitsTicker(currentDays: days)),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),

              // ── Stats Grid ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: _StatsGrid(state: state, days: days, hasStreak: hasStreak),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),

              // ── Urge SOS Row ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: _UrgeSosRow(onUrgePressed: onUrgePressed),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),

              // ── Quote ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'DAILY WISDOM'),
                      SizedBox(height: 12.h),
                      QuoteCard(dayIndex: days + DateTime.now().day),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),

              // ── Next Milestone ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: _NextMilestoneCard(days: days, hasStreak: hasStreak),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),

              // ── Body Reboot Timeline ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'BODY REBOOT TIMELINE'),
                      SizedBox(height: 12.h),
                      _BodyRebootTimeline(days: days),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),

              // ── Daily Habit Tracker ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'DAILY DISCIPLINE'),
                      SizedBox(height: 12.h),
                      const _DailyHabitTracker(),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),

              // ── Cold Shower Challenge ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: _ColdShowerCard(),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),

              // ── Power Mindset ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'WARRIOR MINDSET'),
                      SizedBox(height: 12.h),
                      _PowerMindsetCards(),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        );
      },
    );
  }
}

// ── Cinematic Hero with Custom Painter ──────────────────────────────────────

class _CinematicHero extends StatefulWidget {
  final int days, hours, minutes, seconds;
  final bool hasStreak;
  final VoidCallback onRelapse;
  final VoidCallback onStart;

  const _CinematicHero({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.hasStreak,
    required this.onRelapse,
    required this.onStart,
  });

  @override
  State<_CinematicHero> createState() => _CinematicHeroState();
}

class _CinematicHeroState extends State<_CinematicHero> with SingleTickerProviderStateMixin {
  late AnimationController _rotCtrl;
  bool _relapseExpanded = false;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroH = 480.h;

    return SizedBox(
      width: double.infinity,
      height: heroH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Custom painter background ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rotCtrl,
              builder: (_, __) => CustomPaint(painter: _HeroBackgroundPainter(rotation: _rotCtrl.value * 2 * math.pi)),
            ),
          ),

          // ── Bottom fade (render BEFORE content so it's behind) ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black]),
                ),
              ),
            ),
          ),

          // ── Safe area content (on top of fade) ──
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.h),

                  // ── Header row ──
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.5)),
                            ),
                            ShaderMask(
                              shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                              child: Text(
                                'Rise & Conquer',
                                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _GlassChip(icon: Icons.local_fire_department, label: '${widget.hasStreak ? widget.days : 0}d', color: AppTheme.primary),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Streak display / start button ──
                  Expanded(
                    child: Center(
                      child: widget.hasStreak
                          ? StreakDisplay(days: widget.days, hours: widget.hours, minutes: widget.minutes, seconds: widget.seconds)
                          : _StartStreakButton(onStart: widget.onStart),
                    ),
                  ),

                  // ── Inline relapse area (always ABOVE fade) ──
                  if (widget.hasStreak)
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
                      child: _InlineRelapseRow(
                        expanded: _relapseExpanded,
                        onToggle: () {
                          HapticFeedback.mediumImpact();
                          setState(() => _relapseExpanded = !_relapseExpanded);
                        },
                        onConfirm: () {
                          HapticFeedback.heavyImpact();
                          widget.onRelapse();
                          setState(() => _relapseExpanded = false);
                        },
                        onCancel: () => setState(() => _relapseExpanded = false),
                      ),
                    )
                  else
                    SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Late night warrior 🌙';
    if (h < 12) return 'Good morning, warrior ☀️';
    if (h < 17) return 'Keep pushing, warrior 💪';
    if (h < 21) return 'Stay strong this evening 🔥';
    return 'Night discipline wins 🌟';
  }
}

// ── Hero Background Custom Painter ──────────────────────────────────────────

class _HeroBackgroundPainter extends CustomPainter {
  final double rotation;
  _HeroBackgroundPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep black base
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black);

    // 2. Gold radial glow (top-right)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [AppTheme.primary.withOpacity(0.18), AppTheme.primary.withOpacity(0.07), Colors.transparent],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.75, size.height * 0.20), radius: size.width * 0.7));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // 3. Purple accent (bottom-left)
    final purplePaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF6366F1).withOpacity(0.10), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.15, size.height * 0.85), radius: size.width * 0.5));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), purplePaint);

    // 4. Rotating hex-ring lines
    _drawHexGrid(canvas, size, rotation);

    // 5. Subtle horizontal scan line
    final linePaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.04)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  void _drawHexGrid(Canvas canvas, Size size, double rotation) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.42;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Expanding rings with slight rotation
    final radii = [90.0, 130.0, 175.0, 225.0, 280.0];
    for (final r in radii) {
      final opacity = (1.0 - r / 320.0).clamp(0.02, 0.12);
      ringPaint.color = AppTheme.primary.withOpacity(opacity);

      final path = Path();
      for (int i = 0; i < 6; i++) {
        final angle = rotation * (i.isEven ? 0.3 : -0.2) + (i * math.pi / 3) + math.pi / 6;
        final x = cx + r * math.cos(angle);
        final y = cy + r * math.sin(angle);
        if (i == 0)
          path.moveTo(x, y);
        else
          path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, ringPaint);
    }

    // Spoke lines
    final spokePaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.05)
      ..strokeWidth = 0.6;
    for (int i = 0; i < 12; i++) {
      final angle = rotation * 0.15 + (i * math.pi / 6);
      canvas.drawLine(Offset(cx, cy), Offset(cx + 280 * math.cos(angle), cy + 280 * math.sin(angle)), spokePaint);
    }
  }

  @override
  bool shouldRepaint(_HeroBackgroundPainter old) => old.rotation != rotation;
}

// ── Inline Relapse Row ───────────────────────────────────────────────────────

class _InlineRelapseRow extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _InlineRelapseRow({required this.expanded, required this.onToggle, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return GestureDetector(
        onTap: onToggle,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: AppTheme.statusDanger.withOpacity(0.15), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_dissatisfied_outlined, size: 14.sp, color: AppTheme.statusDanger.withOpacity(0.6)),
                  SizedBox(width: 8.w),
                  Text(
                    'I slipped today',
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.statusDanger.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: AppTheme.statusDanger.withOpacity(0.08),
            border: Border.all(color: AppTheme.statusDanger.withOpacity(0.30), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.statusDanger, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Record a Relapse?',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onCancel,
                    child: Icon(Icons.close, size: 16.sp, color: AppTheme.textMuted),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Every warrior falls. Rise again stronger.',
                style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onCancel,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 11.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'I Can Hold On',
                          style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 11.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: AppTheme.statusDanger,
                          boxShadow: [BoxShadow(color: AppTheme.statusDanger.withOpacity(0.4), blurRadius: 12)],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Record It',
                          style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Start Streak Button ──────────────────────────────────────────────────────

class _StartStreakButton extends StatelessWidget {
  final VoidCallback onStart;
  const _StartStreakButton({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
            child: Icon(Icons.military_tech, size: 72.sp, color: Colors.white),
          ),
          SizedBox(height: 16.h),
          Text(
            'YOUR JOURNEY STARTS NOW',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'Every legend started at day zero.',
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onStart();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: AppTheme.goldGradient,
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: Text(
                'BEGIN MY REBOOT',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final StreakState state;
  final int days;
  final bool hasStreak;
  const _StatsGrid({required this.state, required this.days, required this.hasStreak});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'STATISTICS'),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _GlassStatCard(
                icon: Icons.emoji_events_rounded,
                title: 'Best Streak',
                value: '${state.bestStreakDays}',
                suffix: 'days',
                gradientColors: const [Color(0xFFD4AF37), Color(0xFF9E8229)],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _GlassStatCard(
                icon: Icons.calendar_today_rounded,
                title: 'Current',
                value: hasStreak ? '$days' : '0',
                suffix: 'days',
                gradientColors: const [Color(0xFF60A5FA), Color(0xFF3B82F6)],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _GlassStatCard(
                icon: Icons.refresh_rounded,
                title: 'Relapses',
                value: '${state.totalRelapses}',
                suffix: 'total',
                gradientColors: const [Color(0xFFEF4444), Color(0xFFB91C1C)],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _GlassStatCard(
                icon: Icons.trending_up_rounded,
                title: 'Clean Week',
                value: '${_cleanThisWeek(state)}',
                suffix: 'of 7 days',
                gradientColors: const [Color(0xFF34D399), Color(0xFF059669)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _cleanThisWeek(StreakState state) {
    final now = DateTime.now();
    final relapseDates = {for (final d in state.relapses) DateTime(d.year, d.month, d.day): true};
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      if (!relapseDates.containsKey(DateTime(day.year, day.month, day.day))) count++;
    }
    return count;
  }
}

class _GlassStatCard extends StatelessWidget {
  final IconData icon;
  final String title, value, suffix;
  final List<Color> gradientColors;

  const _GlassStatCard({required this.icon, required this.title, required this.value, required this.suffix, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: gradientColors[0].withOpacity(0.25), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  gradient: LinearGradient(colors: [gradientColors[0].withOpacity(0.25), gradientColors[1].withOpacity(0.10)]),
                ),
                child: Icon(icon, size: 16.sp, color: gradientColors[0]),
              ),
              SizedBox(height: 10.h),
              ShaderMask(
                shaderCallback: (b) => LinearGradient(colors: gradientColors).createShader(b),
                child: Text(
                  value,
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
                ),
              ),
              Text(
                suffix,
                style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted),
              ),
              SizedBox(height: 2.h),
              Text(
                title,
                style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Next Milestone Card ───────────────────────────────────────────────────────

class _NextMilestoneCard extends StatelessWidget {
  final int days;
  final bool hasStreak;
  const _NextMilestoneCard({required this.days, required this.hasStreak});

  @override
  Widget build(BuildContext context) {
    if (!hasStreak) return const SizedBox.shrink();
    final next = _benefits.firstWhere((b) => b.days > days, orElse: () => _benefits.last);
    final prev = _benefits.lastWhere((b) => b.days <= days, orElse: () => _benefits.first);
    final alreadyMax = days >= _benefits.last.days;
    final progress = alreadyMax ? 1.0 : (days - prev.days) / (next.days - prev.days).toDouble();

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary.withOpacity(0.12), Colors.white.withOpacity(0.03)],
        ),
        border: Border.all(color: AppTheme.primary.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(next.icon, style: TextStyle(fontSize: 22.sp)),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alreadyMax ? 'MAX UNLOCKED 🔱' : 'NEXT UNLOCK • Day ${next.days}',
                      style: TextStyle(fontSize: 9.5.sp, color: AppTheme.primary, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      alreadyMax ? prev.text : next.text,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              if (!alreadyMax)
                Text(
                  '${next.days - days}d away',
                  style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                ),
            ],
          ),
          if (!alreadyMax) ...[
            SizedBox(height: 14.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 5.h,
                backgroundColor: Colors.white.withOpacity(0.07),
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Day ${prev.days}',
                  style: TextStyle(fontSize: 9.sp, color: AppTheme.textMuted),
                ),
                Text(
                  'Day ${next.days}',
                  style: TextStyle(fontSize: 9.sp, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Body Reboot Timeline ─────────────────────────────────────────────────────

class _BodyRebootTimeline extends StatelessWidget {
  final int days;
  const _BodyRebootTimeline({required this.days});

  static const _stages = [
    (icon: '💤', day: 3, label: 'Sleep', desc: 'Normalizes'),
    (icon: '🧠', day: 7, label: 'Brain', desc: 'Fog clears'),
    (icon: '⚡', day: 14, label: 'Energy', desc: 'Surges'),
    (icon: '💪', day: 21, label: 'T-Level', desc: 'Peaks'),
    (icon: '👁️', day: 30, label: 'Clarity', desc: 'Full sight'),
    (icon: '🌟', day: 60, label: 'Aura', desc: 'Radiating'),
    (icon: '👑', day: 90, label: 'Freedom', desc: 'Achieved'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _stages.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, i) {
          final s = _stages[i];
          final unlocked = days >= s.day;
          return Container(
            width: 72.w,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              color: unlocked ? AppTheme.primary.withOpacity(0.12) : Colors.white.withOpacity(0.04),
              border: Border.all(color: unlocked ? AppTheme.primary.withOpacity(0.35) : Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(unlocked ? s.icon : '🔒', style: TextStyle(fontSize: 18.sp)),
                SizedBox(height: 4.h),
                Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    color: unlocked ? AppTheme.primary : AppTheme.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  s.desc,
                  style: TextStyle(fontSize: 8.sp, color: AppTheme.textMuted),
                ),
                SizedBox(height: 3.h),
                Text(
                  'D${s.day}',
                  style: TextStyle(fontSize: 8.sp, color: unlocked ? AppTheme.primary.withOpacity(0.6) : AppTheme.textMuted.withOpacity(0.5)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Daily Habit Tracker ───────────────────────────────────────────────────────

class _DailyHabitTracker extends StatefulWidget {
  const _DailyHabitTracker();
  @override
  State<_DailyHabitTracker> createState() => _DailyHabitTrackerState();
}

class _DailyHabitTrackerState extends State<_DailyHabitTracker> {
  static const _habits = [
    (emoji: '🏃', name: 'Exercise'),
    (emoji: '💧', name: 'Hydrate'),
    (emoji: '📖', name: 'Read'),
    (emoji: '🌿', name: 'Outdoors'),
    (emoji: '🧘', name: 'Breathe'),
  ];
  final Set<int> _done = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_habits.length, (i) {
              final h = _habits[i];
              final done = _done.contains(i);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (done)
                      _done.remove(i);
                    else
                      _done.add(i);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 54.w,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    color: done ? AppTheme.primary.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                    border: Border.all(color: done ? AppTheme.primary.withOpacity(0.4) : Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Text(h.emoji, style: TextStyle(fontSize: 18.sp)),
                      SizedBox(height: 4.h),
                      Text(
                        h.name,
                        style: TextStyle(fontSize: 8.5.sp, color: done ? AppTheme.primary : AppTheme.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 10.h),
          Row(
            children: List.generate(
              _habits.length,
              (i) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < _habits.length - 1 ? 4.w : 0),
                  height: 3.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.r),
                    color: _done.contains(i) ? AppTheme.primary : Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${_done.length}/${_habits.length} disciplines completed',
            style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Cold Shower Card ─────────────────────────────────────────────────────────

class _ColdShowerCard extends StatelessWidget {
  _ColdShowerCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen()));
      },
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF38BDF8).withOpacity(0.10), Colors.white.withOpacity(0.02)],
          ),
          border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r), color: const Color(0xFF38BDF8).withOpacity(0.15)),
              child: Text('🚿', style: TextStyle(fontSize: 24.sp)),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cold Shower Reset',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                  Text(
                    '2 min of cold = 4h of clarity. Immediately resets dopamine.',
                    style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted, height: 1.5),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: const Color(0xFF38BDF8).withOpacity(0.2),
                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5)),
              ),
              child: Text(
                'Go!',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF38BDF8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Power Mindset Cards ───────────────────────────────────────────────────────

class _PowerMindsetCards extends StatelessWidget {
  static const _cards = [
    (icon: '🔥', title: 'No Retreat', body: 'Champions are built when no one watches. Keep going.'),
    (icon: '⚔️', title: 'Warrior Mode', body: 'You are at war with your lower self. Win every single day.'),
    (icon: '🌊', title: 'Stay Hard', body: 'Urges are waves. Waves always break. Always.'),
  ];
  const _PowerMindsetCards();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _cards.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, i) {
          final c = _cards[i];
          return Container(
            width: 185.w,
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary.withOpacity(0.09), Colors.white.withOpacity(0.03)],
              ),
              border: Border.all(color: AppTheme.primary.withOpacity(0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(c.icon, style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 6.w),
                    Text(
                      c.title,
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppTheme.primary),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Expanded(
                  child: Text(
                    c.body,
                    style: TextStyle(fontSize: 10.5.sp, color: AppTheme.textSecondary, height: 1.55),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Benefits Ticker ──────────────────────────────────────────────────────────

class _BenefitsTicker extends StatelessWidget {
  final int currentDays;
  const _BenefitsTicker({required this.currentDays});

  @override
  Widget build(BuildContext context) {
    final unlocked = _benefits.where((b) => currentDays >= b.days).toList().reversed.toList();
    final next = _benefits.cast<({int days, String icon, String text})?>().firstWhere((b) => b != null && currentDays < b.days, orElse: () => null);

    if (unlocked.isEmpty && next == null) return const SizedBox();

    return SizedBox(
      height: 38.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        children: [
          if (next != null) _BenefitChip(icon: next.icon, text: 'At ${next.days}d: ${next.text}', unlocked: false),
          ...unlocked.map((b) => _BenefitChip(icon: b.icon, text: b.text, unlocked: true)),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final String icon, text;
  final bool unlocked;
  const _BenefitChip({required this.icon, required this.text, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: unlocked ? AppTheme.primary.withOpacity(0.12) : Colors.white.withOpacity(0.04),
        border: Border.all(color: unlocked ? AppTheme.primary.withOpacity(0.35) : Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: 12.sp)),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: unlocked ? AppTheme.primary : AppTheme.textMuted,
              fontWeight: unlocked ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (unlocked) ...[SizedBox(width: 4.w), Icon(Icons.check_circle, size: 10.sp, color: AppTheme.statusSuccess)],
        ],
      ),
    );
  }
}

// ── Urge SOS Row ─────────────────────────────────────────────────────────────

class _UrgeSosRow extends StatelessWidget {
  final VoidCallback? onUrgePressed;
  const _UrgeSosRow({this.onUrgePressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'QUICK SOS'),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _SosButton(icon: Icons.air, label: 'Breathe', color: const Color(0xFF818CF8), onTap: onUrgePressed),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _SosButton(
                icon: Icons.shower_outlined,
                label: 'Cold Shower',
                color: const Color(0xFF38BDF8),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onUrgePressed?.call();
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _SosButton(
                icon: Icons.bolt,
                label: 'I Feel Urge',
                color: AppTheme.primary,
                onTap: () {
                  HapticFeedback.heavyImpact();
                  onUrgePressed?.call();
                },
                isPrimary: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SosButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _SosButton({required this.icon, required this.label, required this.color, this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: isPrimary ? AppTheme.goldGradient : LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
              border: Border.all(color: color.withOpacity(isPrimary ? 0 : 0.3)),
              boxShadow: isPrimary ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4))] : null,
            ),
            child: Column(
              children: [
                Icon(icon, size: 20.sp, color: isPrimary ? Colors.black : color),
                SizedBox(height: 5.h),
                Text(
                  label,
                  style: TextStyle(fontSize: 10.sp, color: isPrimary ? Colors.black : color, fontWeight: FontWeight.w700),
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

// ── Shared Widgets ──────────────────────────────────────────────────────────

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

class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _GlassChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.sp, color: color),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
