import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';
import 'package:nofap_reboot/bloc/streak_cubit.dart';

/// Urge Heatmap — calendar heatmap showing relapse/urge patterns.
class UrgeHeatmapScreen extends StatelessWidget {
  const UrgeHeatmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakState>(
      builder: (context, state) {
        final relapseDates = { for (final d in state.relapses) DateTime(d.year, d.month, d.day): true };
        final startDate = state.startDate;
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned(
                bottom: -80,
                left: -60,
                child: Container(
                  width: 280.w,
                  height: 280.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [const Color(0xFF6366F1).withOpacity(0.07), Colors.transparent]),
                  ),
                ),
              ),
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
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
                                Text('🔥 URGE HEATMAP', style: TextStyle(fontSize: 10.sp, color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.w700)),
                                Text('Visual Pattern Analysis', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                    // Legend
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            _LegendDot(color: AppTheme.statusSuccess, label: 'Clean'),
                            SizedBox(width: 16.w),
                            _LegendDot(color: AppTheme.statusDanger, label: 'Relapse'),
                            SizedBox(width: 16.w),
                            _LegendDot(color: Colors.white.withOpacity(0.1), label: 'No data'),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                    // Last 12 weeks heatmap
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: _HeatmapGrid(relapseDates: relapseDates, startDate: startDate),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // Weekday stats
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: _WeekdayStats(relapseDates: relapseDates),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                    // Stats row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: _StatsRow(relapseCount: relapseDates.length, startDate: startDate),
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 12.w, height: 12.w, decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.r), color: color)),
      SizedBox(width: 6.w),
      Text(label, style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
    ],
  );
}

class _HeatmapGrid extends StatelessWidget {
  final Map<DateTime, bool> relapseDates;
  final DateTime? startDate;
  const _HeatmapGrid({required this.relapseDates, required this.startDate});

  Color _dayColor(DateTime day, DateTime? start) {
    final key = DateTime(day.year, day.month, day.day);
    final inRange = start != null && !day.isBefore(DateTime(start.year, start.month, start.day));
    if (!inRange) return Colors.transparent;
    if (relapseDates.containsKey(key)) return AppTheme.statusDanger;
    if (day.isBefore(DateTime.now())) return AppTheme.statusSuccess.withOpacity(0.7);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Go back 16 weeks
    final weeksBack = 16;
    final startOfGrid = now.subtract(Duration(days: weeksBack * 7 + now.weekday - 1));

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LAST 16 WEEKS', style: TextStyle(fontSize: 9.sp, color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.w700)),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels
              Column(
                children: List.generate(7, (i) => Container(
                  height: 14.h,
                  margin: EdgeInsets.only(bottom: 3.h),
                  child: Text(dayLabels[i], style: TextStyle(fontSize: 8.sp, color: AppTheme.textMuted)),
                )),
              ),
              SizedBox(width: 6.w),
              // Grid
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(weeksBack + 1, (week) {
                      return Column(
                        children: List.generate(7, (dow) {
                          final day = startOfGrid.add(Duration(days: week * 7 + dow));
                          final color = _dayColor(day, startDate);
                          final isFuture = day.isAfter(now);
                          return Container(
                            width: 12.w,
                            height: 12.w,
                            margin: EdgeInsets.only(right: 3.w, bottom: 3.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.r),
                              color: isFuture ? Colors.transparent : color == Colors.transparent ? Colors.white.withOpacity(0.06) : color,
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekdayStats extends StatelessWidget {
  final Map<DateTime, bool> relapseDates;
  const _WeekdayStats({required this.relapseDates});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final counts = List.filled(7, 0);
    for (final d in relapseDates.keys) {
      counts[d.weekday - 1]++;
    }
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) return const SizedBox.shrink();

    final riskiestIndex = counts.indexOf(maxCount);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RELAPSES BY DAY', style: TextStyle(fontSize: 9.sp, color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Text('${_days[riskiestIndex]}day is your riskiest day', style: TextStyle(fontSize: 12.sp, color: AppTheme.statusDanger, fontWeight: FontWeight.w700)),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final ratio = maxCount > 0 ? counts[i] / maxCount : 0.0;
              final isRiskiest = i == riskiestIndex;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Column(
                    children: [
                      Text('${counts[i]}', style: TextStyle(fontSize: 8.sp, color: isRiskiest ? AppTheme.statusDanger : AppTheme.textMuted)),
                      SizedBox(height: 3.h),
                      Container(
                        height: 60.h * ratio + 4.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                          color: isRiskiest ? AppTheme.statusDanger : Colors.white.withOpacity(0.15),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(_days[i].substring(0, 2), style: TextStyle(fontSize: 8.sp, color: isRiskiest ? AppTheme.statusDanger : AppTheme.textMuted, fontWeight: isRiskiest ? FontWeight.w700 : FontWeight.w400)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int relapseCount;
  final DateTime? startDate;
  const _StatsRow({required this.relapseCount, required this.startDate});

  @override
  Widget build(BuildContext context) {
    final totalDays = startDate != null ? DateTime.now().difference(startDate!).inDays + 1 : 0;
    final cleanDays = (totalDays - relapseCount).clamp(0, totalDays);
    final cleanPct = totalDays > 0 ? (cleanDays / totalDays * 100).round() : 0;

    return Row(
      children: [
        Expanded(child: _StatBox(value: '$cleanPct%', label: 'Clean Rate', color: AppTheme.statusSuccess)),
        SizedBox(width: 10.w),
        Expanded(child: _StatBox(value: '$cleanDays', label: 'Clean Days', color: AppTheme.primary)),
        SizedBox(width: 10.w),
        Expanded(child: _StatBox(value: '$relapseCount', label: 'Relapses', color: AppTheme.statusDanger)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatBox({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 14.h),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14.r),
      color: color.withOpacity(0.08),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: TextStyle(fontSize: 9.sp, color: AppTheme.textMuted), textAlign: TextAlign.center),
      ],
    ),
  );
}
