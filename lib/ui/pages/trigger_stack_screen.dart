import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

class TriggerStackScreen extends StatefulWidget {
  const TriggerStackScreen({super.key});
  @override
  State<TriggerStackScreen> createState() => _TriggerStackScreenState();
}

class _TriggerStackScreenState extends State<TriggerStackScreen> {
  final Set<int> _active = {};

  static const _triggers = [
    (emoji: '🌙', label: 'Night (9PM+)', category: 'time'),
    (emoji: '☀️', label: 'Morning (7-9AM)', category: 'time'),
    (emoji: '🏠', label: 'Alone at Home', category: 'location'),
    (emoji: '😔', label: 'Feeling Lonely', category: 'emotion'),
    (emoji: '😤', label: 'Stressed / Bored', category: 'emotion'),
    (emoji: '📱', label: 'Social Media Open', category: 'app'),
    (emoji: '😴', label: 'Sleep Deprived', category: 'physical'),
    (emoji: '🍕', label: 'Just Finished Eating', category: 'physical'),
    (emoji: '📺', label: 'Watching Alone', category: 'app'),
    (emoji: '💤', label: 'Late in Bed', category: 'time'),
    (emoji: '😡', label: 'Angry / Frustrated', category: 'emotion'),
    (emoji: '📵', label: 'Nothing to Do', category: 'emotion'),
  ];

  // Risk combos (indices into _triggers)
  static const _riskCombos = [
    ([0, 2, 5], 'CRITICAL', 'Night + Home + Social Media — this combo caused most relapses. Get off now!'),
    ([0, 4, 9], 'CRITICAL', 'Night + Stressed + Bed — classic high-risk stack. Move to a different room immediately.'),
    ([7, 4, 3], 'HIGH', 'Bored + Lonely + Just ate — your brain is seeking dopamine. Go for a walk.'),
    ([2, 3, 5], 'HIGH', 'Alone + Lonely + Social Media — empty scroll loop. Put the phone down.'),
    ([6, 0, 9], 'HIGH', 'Sleep deprived + Night + Bed — exhaustion kills willpower. Sleep is protection.'),
  ];

  String get _riskLevel {
    final active = _active.toList();
    for (final (combo, level, _) in _riskCombos) {
      if (combo.every((i) => active.contains(i))) return level;
    }
    if (_active.length >= 4) return 'ELEVATED';
    if (_active.length >= 2) return 'MODERATE';
    return 'LOW';
  }

  String get _riskMessage {
    final active = _active.toList();
    for (final (combo, _, msg) in _riskCombos) {
      if (combo.every((i) => active.contains(i))) return msg;
    }
    if (_active.length >= 4) return 'You\'re stacking multiple triggers. Stay alert and change your environment now.';
    if (_active.length >= 2) return 'Some risk factors present. Increase awareness. Don\'t isolate.';
    return 'You\'re in a safe zone. Keep your guard up.';
  }

  Color get _riskColor {
    switch (_riskLevel) {
      case 'CRITICAL': return AppTheme.statusDanger;
      case 'HIGH': return const Color(0xFFF59E0B);
      case 'ELEVATED': return const Color(0xFFF59E0B);
      default: return AppTheme.statusSuccess;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.arrow_back_ios_new, color: AppTheme.textMuted, size: 16.sp)),
                  ),
                  SizedBox(width: 14.w),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('🧠 TRIGGER STACK', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF818CF8), letterSpacing: 2, fontWeight: FontWeight.w700)),
                    Text('Pattern Detector', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                  ]),
                ]),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 16.h)),

            // Risk indicator
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: _riskColor.withOpacity(0.10),
                    border: Border.all(color: _riskColor.withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    SizedBox(
                      width: 44.w, height: 44.w,
                      child: Stack(alignment: Alignment.center, children: [
                        CircularProgressIndicator(
                          value: _active.length / _triggers.length,
                          strokeWidth: 4.5,
                          backgroundColor: Colors.white.withOpacity(0.07),
                          valueColor: AlwaysStoppedAnimation<Color>(_riskColor),
                        ),
                        Text('${_active.length}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: _riskColor)),
                      ]),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_riskLevel, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: _riskColor, letterSpacing: 1.5)),
                      SizedBox(height: 3.h),
                      Text(_riskMessage, style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary, height: 1.4)),
                    ])),
                  ]),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text('SELECT ACTIVE TRIGGERS', style: TextStyle(fontSize: 9.sp, color: AppTheme.primary, letterSpacing: 2.5, fontWeight: FontWeight.w700)),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10.h)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8.w, mainAxisSpacing: 8.h, childAspectRatio: 3.0),
                delegate: SliverChildBuilderDelegate((_, i) {
                  final t = _triggers[i];
                  final selected = _active.contains(i);
                  final catColor = t.category == 'time' ? const Color(0xFF818CF8)
                      : t.category == 'emotion' ? AppTheme.statusDanger
                      : t.category == 'physical' ? const Color(0xFFF59E0B)
                      : AppTheme.primary;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() { if (selected) _active.remove(i); else _active.add(i); });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: selected ? catColor.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                        border: Border.all(color: selected ? catColor.withOpacity(0.5) : Colors.white.withOpacity(0.08), width: selected ? 1.5 : 1),
                      ),
                      child: Row(children: [
                        Text(t.emoji, style: TextStyle(fontSize: 16.sp)),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(t.label, style: TextStyle(fontSize: 10.5.sp, color: selected ? AppTheme.textPrimary : AppTheme.textMuted, fontWeight: selected ? FontWeight.w700 : FontWeight.w400), overflow: TextOverflow.ellipsis)),
                      ]),
                    ),
                  );
                }, childCount: _triggers.length),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 16.h)),

            if (_active.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: GestureDetector(
                    onTap: () { setState(() => _active.clear()); HapticFeedback.lightImpact(); },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r), border: Border.all(color: Colors.white.withOpacity(0.12)), color: Colors.white.withOpacity(0.03)),
                      alignment: Alignment.center,
                      child: Text('Clear All', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
                    ),
                  ),
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }
}
