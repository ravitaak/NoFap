import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

/// Urge Prediction System — shows risky time windows and pattern alerts.
class UrgePredictionScreen extends StatelessWidget {
  const UrgePredictionScreen({super.key});

  // Simulated risk data (hours 0–23)
  static const _hourlyRisk = [
    0.1, 0.1, 0.15, 0.1, 0.05, 0.05, 0.08, 0.1,
    0.15, 0.2, 0.2, 0.2, 0.18, 0.15, 0.15, 0.18,
    0.22, 0.25, 0.3, 0.45, 0.6, 0.75, 0.7, 0.4,
  ];

  static const _riskyZones = [
    (label: '9PM – 11PM', icon: '🌙', risk: 'High', color: Color(0xFFEF4444)),
    (label: '11PM – 1AM', icon: '🔴', risk: 'Critical', color: Color(0xFFEF4444)),
    (label: '7AM – 9AM', icon: '🌅', risk: 'Moderate', color: Color(0xFFF59E0B)),
    (label: 'Weekends', icon: '📅', risk: 'Elevated', color: Color(0xFFF59E0B)),
  ];

  static const _patterns = [
    '🧠 Peak urge times are between 9PM–1AM',
    '📵 You tend to open social media before urges',
    '😴 Sleep deprivation increases risk 3×',
    '📆 Saturday nights are historically your riskiest',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final risk = _hourlyRisk[currentHour];
    final isHighRisk = risk > 0.5;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background ambient
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 300.w,
              height: 300.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(0.08),
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
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(Icons.arrow_back_ios_new, color: AppTheme.textMuted, size: 16.sp),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('⚡ URGE PREDICTOR', style: TextStyle(fontSize: 10.sp, color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.w700)),
                            Text('Pattern Analysis', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                // Current Risk Gauge
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _RiskGaugeCard(risk: risk, isHighRisk: isHighRisk, hour: currentHour),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                // 24h Risk Bar Chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _24HourRiskChart(currentHour: currentHour),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                // Risky Zones
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _SectionLabel(label: 'DANGER WINDOWS'),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                      child: _RiskyZoneCard(zone: _riskyZones[i]),
                    ),
                    childCount: _riskyZones.length,
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 8.h)),

                // Pattern Insights
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _SectionLabel(label: 'AI PATTERN INSIGHTS'),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        color: AppTheme.primary.withOpacity(0.06),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                      ),
                      child: Column(
                        children: _patterns.map((p) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.substring(0, 2), style: TextStyle(fontSize: 14.sp)),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(p.substring(2), style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary, height: 1.5)),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                // Notification toggle
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _AlertToggleCard(),
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 3, height: 14.h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.primaryBright, AppTheme.goldDark]))),
      SizedBox(width: 8.w),
      Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 2.5)),
    ],
  );
}

class _RiskGaugeCard extends StatelessWidget {
  final double risk;
  final bool isHighRisk;
  final int hour;
  const _RiskGaugeCard({required this.risk, required this.isHighRisk, required this.hour});

  String get _riskLabel {
    if (risk < 0.3) return 'LOW RISK';
    if (risk < 0.6) return 'MODERATE';
    return 'HIGH RISK';
  }

  Color get _riskColor {
    if (risk < 0.3) return AppTheme.statusSuccess;
    if (risk < 0.6) return const Color(0xFFF59E0B);
    return AppTheme.statusDanger;
  }

  String get _hourLabel {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final ampm = hour < 12 ? 'AM' : 'PM';
    return '$h:00 $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_riskColor.withOpacity(0.12), Colors.white.withOpacity(0.03)],
        ),
        border: Border.all(color: _riskColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(isHighRisk ? '⚠️' : '✅', style: TextStyle(fontSize: 28.sp)),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_riskLabel, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: _riskColor, letterSpacing: 1.5)),
                    Text('Right now • $_hourLabel', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                    Text(
                      isHighRisk ? 'Stay strong. This is a danger zone.' : 'You\'re in a safe window. Keep going.',
                      style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 52.w,
                height: 52.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: risk.clamp(0.0, 1.0),
                      strokeWidth: 5,
                      backgroundColor: Colors.white.withOpacity(0.07),
                      valueColor: AlwaysStoppedAnimation<Color>(_riskColor),
                    ),
                    Text('${(risk * 100).round()}%', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: _riskColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _24HourRiskChart extends StatelessWidget {
  final int currentHour;
  static const _risk = UrgePredictionScreen._hourlyRisk;

  const _24HourRiskChart({required this.currentHour});

  Color _barColor(double r) {
    if (r < 0.3) return AppTheme.statusSuccess;
    if (r < 0.55) return const Color(0xFFF59E0B);
    return AppTheme.statusDanger;
  }

  @override
  Widget build(BuildContext context) {
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
          Text('24-HOUR RISK WINDOW', style: TextStyle(fontSize: 9.sp, color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.w700)),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(24, (h) {
              final r = _risk[h];
              final isCurrent = h == currentHour;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCurrent)
                        Container(
                          width: 4.w,
                          height: 4.w,
                          margin: EdgeInsets.only(bottom: 2.h),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: double.infinity,
                        height: 60.h * r + 6.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(3.r)),
                          color: isCurrent ? AppTheme.primary : _barColor(r).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['12AM', '6AM', '12PM', '6PM', '12AM']
                .map((t) => Text(t, style: TextStyle(fontSize: 7.5.sp, color: AppTheme.textMuted)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RiskyZoneCard extends StatelessWidget {
  final ({String label, String icon, String risk, Color color}) zone;
  const _RiskyZoneCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: zone.color.withOpacity(0.08),
        border: Border.all(color: zone.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(zone.icon, style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 12.w),
          Expanded(child: Text(zone.label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r), color: zone.color.withOpacity(0.15), border: Border.all(color: zone.color.withOpacity(0.3))),
            child: Text(zone.risk, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: zone.color)),
          ),
        ],
      ),
    );
  }
}

class _AlertToggleCard extends StatefulWidget {
  @override
  State<_AlertToggleCard> createState() => _AlertToggleCardState();
}

class _AlertToggleCardState extends State<_AlertToggleCard> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(colors: [AppTheme.primary.withOpacity(0.1), Colors.transparent]),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active, color: AppTheme.primary, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smart Alerts', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                Text('Get warned 30 min before your risky window', style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            onChanged: (v) { HapticFeedback.selectionClick(); setState(() => _enabled = v); },
            activeColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withOpacity(0.3),
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
