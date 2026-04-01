import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';
import 'package:nofap_reboot/bloc/streak_cubit.dart';
import 'package:nofap_reboot/ui/widgets/achievement_badge.dart';
import 'package:table_calendar/table_calendar.dart';

class AscendTab extends StatefulWidget {
  const AscendTab({super.key});

  @override
  State<AscendTab> createState() => _AscendTabState();
}

class _AscendTabState extends State<AscendTab> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakState>(
      builder: (context, state) {
        final relapses = state.relapses;
        final relapseDates = {for (final d in relapses) DateTime(d.year, d.month, d.day): true};

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned(
                top: -60,
                left: -60,
                child: Container(
                  width: 240.w,
                  height: 240.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [AppTheme.primary.withOpacity(0.05), Colors.transparent]),
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
                              'Ascend',
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                                fontFamily: 'Delius',
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                              child: Text(
                                'YOUR PROGRESS',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                  fontFamily: 'Delius',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                    // ── Streak Chart ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'STREAK HISTORY'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _GlassChart(
                          padding: EdgeInsets.fromLTRB(8.w, 20.h, 12.w, 12.h),
                          child: SizedBox(
                            height: 160.h,
                            child: _StreakChart(state: state),
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Calendar ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'CALENDAR'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                color: Colors.white.withOpacity(0.04),
                                border: Border.all(color: AppTheme.primary.withOpacity(0.18)),
                              ),
                              child: TableCalendar(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.now(),
                                focusedDay: _focusedDay,
                                onPageChanged: (d) => setState(() => _focusedDay = d),
                                calendarFormat: CalendarFormat.month,
                                availableGestures: AvailableGestures.horizontalSwipe,
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                    fontFamily: 'Delius',
                                  ),
                                  leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.primary, size: 20.sp),
                                  rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.primary, size: 20.sp),
                                  headerPadding: EdgeInsets.only(bottom: 8.h),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted, fontFamily: 'Delius'),
                                  weekendStyle: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted, fontFamily: 'Delius'),
                                ),
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  defaultTextStyle: TextStyle(fontSize: 12.sp, color: AppTheme.textPrimary, fontFamily: 'Delius'),
                                  weekendTextStyle: TextStyle(fontSize: 12.sp, color: AppTheme.textPrimary, fontFamily: 'Delius'),
                                  todayDecoration: BoxDecoration(
                                    color: AppTheme.primaryGlow,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.primary, width: 1.5),
                                  ),
                                  todayTextStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Delius',
                                  ),
                                  selectedDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                                  selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                                  markerDecoration: BoxDecoration(color: AppTheme.statusDanger, shape: BoxShape.circle),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  defaultBuilder: (ctx, day, focused) {
                                    final key = DateTime(day.year, day.month, day.day);
                                    final isRelapse = relapseDates.containsKey(key);
                                    final isClean = _isCleanDay(day, state, relapseDates);
                                    if (isRelapse) {
                                      return _CalendarDay(day: day, color: AppTheme.statusDanger);
                                    } else if (isClean) {
                                      return _CalendarDay(day: day, color: AppTheme.statusSuccess);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Insights ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'INSIGHTS'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: _InsightCard(
                                icon: Icons.schedule,
                                title: 'Most Risky',
                                value: _mostRiskyTime(relapses),
                                subtitle: 'time of day',
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _InsightCard(
                                icon: Icons.trending_up,
                                title: 'This Week',
                                value: '${_weeklyCleanDays(state)}',
                                subtitle: 'clean days',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Benefits Timeline ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'BENEFITS UNLOCKED'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                    SliverToBoxAdapter(child: _BenefitsTimeline(currentDays: state.currentStreakDays)),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Mood Tracker ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'TODAY\'S MOOD'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _MoodTracker(),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Achievements ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'ACHIEVEMENTS'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                color: Colors.white.withOpacity(0.04),
                                border: Border.all(color: AppTheme.primary.withOpacity(0.18)),
                              ),
                              child: Wrap(
                                spacing: 16.w,
                                runSpacing: 16.h,
                                alignment: WrapAlignment.center,
                                children: achievements.map((a) {
                                  return AchievementBadge(def: a, unlocked: state.bestStreakDays >= a.requiredDays);
                                }).toList(),
                              ),
                            ),
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

  bool _isCleanDay(DateTime day, StreakState state, Map<DateTime, bool> relapseDates) {
    if (state.startDate == null) return false;
    final key = DateTime(day.year, day.month, day.day);
    if (relapseDates.containsKey(key)) return false;
    if (day.isAfter(DateTime.now())) return false;
    if (day.isBefore(DateTime(state.startDate!.year, state.startDate!.month, state.startDate!.day))) return false;
    return true;
  }

  String _mostRiskyTime(List<DateTime> relapses) {
    if (relapses.isEmpty) return 'N/A';
    final hours = <int>[];
    for (final r in relapses) {
      hours.add(r.hour);
    }
    final freq = <int, int>{};
    for (final h in hours) {
      freq[h] = (freq[h] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final h = sorted.first.key;
    if (h < 6) return 'Night';
    if (h < 12) return 'Morning';
    if (h < 18) return 'Afternoon';
    return 'Evening';
  }

  int _weeklyCleanDays(StreakState state) {
    int count = 0;
    final now = DateTime.now();
    final relapseDates = {for (final d in state.relapses) DateTime(d.year, d.month, d.day): true};
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final key = DateTime(day.year, day.month, day.day);
      if (!relapseDates.containsKey(key)) count++;
    }
    return count;
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
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 2.5),
        ),
      ],
    );
  }
}

// ── Glass chart container ────────────────────────────────────────────────────

class _GlassChart extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _GlassChart({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: AppTheme.primary.withOpacity(0.18), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Benefits Timeline ────────────────────────────────────────────────────────

const _milestones = [
  (days: 1, emoji: '⚡', benefit: 'Dopamine stabilizing', detail: 'Energy starting to return'),
  (days: 7, emoji: '🧠', benefit: 'Brain fog lifting', detail: 'Mental clarity improves'),
  (days: 14, emoji: '💪', benefit: 'Testosterone +45%', detail: 'Peak male hormone surge'),
  (days: 30, emoji: '🏆', benefit: 'Deep confidence', detail: 'Social presence amplified'),
  (days: 60, emoji: '🌟', benefit: 'Attraction elevated', detail: 'People notice the change'),
  (days: 90, emoji: '👑', benefit: 'Full rewire', detail: 'New baseline established'),
  (days: 180, emoji: '🔱', benefit: 'Ascendant mind', detail: 'Rare level of discipline'),
  (days: 365, emoji: '♾️', benefit: 'Reborn', detail: 'True self fully reclaimed'),
];

class _BenefitsTimeline extends StatelessWidget {
  final int currentDays;
  const _BenefitsTimeline({required this.currentDays});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: _milestones.length,
        itemBuilder: (ctx, i) {
          final m = _milestones[i];
          final unlocked = currentDays >= m.days;
          return Container(
            width: 110.w,
            margin: EdgeInsets.only(right: 10.w),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: unlocked ? AppTheme.primary.withOpacity(0.10) : Colors.white.withOpacity(0.03),
              border: Border.all(color: unlocked ? AppTheme.primary.withOpacity(0.35) : Colors.white.withOpacity(0.07)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(m.emoji, style: TextStyle(fontSize: 18.sp)),
                    const Spacer(),
                    if (unlocked) Icon(Icons.check_circle_rounded, size: 14.sp, color: AppTheme.statusSuccess),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Day ${m.days}',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: unlocked ? AppTheme.primary : AppTheme.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  m.benefit,
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: unlocked ? AppTheme.textPrimary : AppTheme.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  m.detail,
                  style: TextStyle(fontSize: 9.sp, color: AppTheme.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Mood Tracker ─────────────────────────────────────────────────────────────

class _MoodTracker extends StatefulWidget {
  @override
  State<_MoodTracker> createState() => _MoodTrackerState();
}

class _MoodTrackerState extends State<_MoodTracker> {
  int? _selected;

  static const _moods = [('😫', 'Struggling'), ('😕', 'Meh'), ('😐', 'Okay'), ('😊', 'Good'), ('🔥', 'Unstoppable')];

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
            border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_moods.length, (i) {
                  final selected = _selected == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 52.w,
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        color: selected ? AppTheme.primary.withOpacity(0.2) : Colors.transparent,
                        border: Border.all(color: selected ? AppTheme.primary : Colors.transparent, width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_moods[i].$1, style: TextStyle(fontSize: 22.sp)),
                          SizedBox(height: 3.h),
                          Text(
                            _moods[i].$2,
                            style: TextStyle(
                              fontSize: 7.5.sp,
                              color: selected ? AppTheme.primary : AppTheme.textMuted,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              if (_selected != null) ...[
                SizedBox(height: 12.h),
                Text(
                  'Logged! Keep going, warrior. 🔥',
                  style: TextStyle(fontSize: 11.sp, color: AppTheme.statusSuccess, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _InsightCard({required this.icon, required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: AppTheme.primary.withOpacity(0.20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: AppTheme.primary.withOpacity(0.15)),
                child: Icon(icon, size: 16.sp, color: AppTheme.primary),
              ),
              SizedBox(height: 10.h),
              ShaderMask(
                shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                child: Text(
                  value,
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime day;
  final Color color;
  const _CalendarDay({required this.day, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.18),
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.w600, fontFamily: 'Delius'),
        ),
      ),
    );
  }
}

class _StreakChart extends StatelessWidget {
  final StreakState state;
  const _StreakChart({required this.state});

  List<FlSpot> _buildSpots() {
    final List<FlSpot> spots = [];
    final relapses = List<DateTime>.from(state.relapses)..sort();

    if (relapses.isEmpty) {
      final days = state.currentStreakDays.toDouble();
      spots.add(const FlSpot(0, 0));
      spots.add(FlSpot(1, days));
      return spots;
    }

    DateTime? startAnchor;
    for (int i = 0; i < relapses.length; i++) {
      final d = relapses[i];
      final prev = i == 0 ? (state.startDate ?? d) : relapses[i - 1];
      final streakLen = d.difference(prev).inDays.toDouble();
      startAnchor = d;
      spots.add(FlSpot(i.toDouble(), streakLen.clamp(0, 999)));
    }

    final current = DateTime.now().difference(startAnchor!).inDays.toDouble();
    spots.add(FlSpot(relapses.length.toDouble(), current.clamp(0, 999)));

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b).clamp(1, 999);

    return LineChart(
      LineChartData(
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 3).clamp(1, 999),
          getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.surfaceBorder, strokeWidth: 1, dashArray: [4, 4]),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.w,
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}d',
                style: TextStyle(fontSize: 9.sp, color: AppTheme.textMuted, fontFamily: 'Delius'),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22.h,
              getTitlesWidget: (v, _) => Text(
                '#${(v + 1).toInt()}',
                style: TextStyle(fontSize: 9.sp, color: AppTheme.textMuted, fontFamily: 'Delius'),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppTheme.primary,
            barWidth: 3.5,
            isStrokeCapRound: true,
            shadow: Shadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 10),
            dotData: FlDotData(
              show: true,
              getDotPainter: (s, _, __, ___) => FlDotCirclePainter(radius: 4, color: AppTheme.primary, strokeColor: Colors.black, strokeWidth: 1.5),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.primary.withOpacity(0.20), AppTheme.primary.withOpacity(0.00)],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.surfaceElevated,
            tooltipBorder: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
            getTooltipItems: (spots) => spots
                .map(
                  (s) => LineTooltipItem(
                    '${s.y.toInt()} days',
                    TextStyle(color: AppTheme.primary, fontSize: 11.sp, fontWeight: FontWeight.w600, fontFamily: 'Delius'),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
