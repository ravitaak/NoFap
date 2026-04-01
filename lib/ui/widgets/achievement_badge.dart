import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

class AchievementDef {
  final String title;
  final int requiredDays;
  final IconData icon;

  const AchievementDef({required this.title, required this.requiredDays, required this.icon});
}

const List<AchievementDef> achievements = [
  AchievementDef(title: 'Warrior', requiredDays: 1, icon: Icons.shield),
  AchievementDef(title: 'Champion', requiredDays: 3, icon: Icons.star),
  AchievementDef(title: 'Conqueror', requiredDays: 7, icon: Icons.military_tech),
  AchievementDef(title: 'Titan', requiredDays: 14, icon: Icons.bolt),
  AchievementDef(title: 'Legend', requiredDays: 30, icon: Icons.workspace_premium),
  AchievementDef(title: 'Monk', requiredDays: 60, icon: Icons.self_improvement),
  AchievementDef(title: 'Ascendant', requiredDays: 90, icon: Icons.arrow_upward),
  AchievementDef(title: 'Immortal', requiredDays: 180, icon: Icons.local_fire_department),
  AchievementDef(title: 'Reborn', requiredDays: 365, icon: Icons.wb_sunny),
];

class AchievementBadge extends StatelessWidget {
  final AchievementDef def;
  final bool unlocked;
  final bool large;

  const AchievementBadge({super.key, required this.def, required this.unlocked, this.large = false});

  @override
  Widget build(BuildContext context) {
    final size = large ? 72.w : 56.w;
    final iconSize = large ? 26.sp : 20.sp;
    final fontSize = large ? 10.sp : 8.5.sp;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked ? AppTheme.primaryGlow : AppTheme.surfaceBase,
            border: Border.all(color: unlocked ? AppTheme.primary.withOpacity(0.6) : AppTheme.surfaceBorder, width: 1.5),
            boxShadow: unlocked ? [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 18, spreadRadius: -2)] : [],
            gradient: unlocked ? RadialGradient(colors: [AppTheme.primary.withOpacity(0.15), AppTheme.primaryGlow]) : null,
          ),
          child: Icon(def.icon, size: iconSize, color: unlocked ? AppTheme.primary : AppTheme.textMuted),
        ),
        SizedBox(height: 4.h),
        SizedBox(
          width: size + 4.w,
          child: Text(
            def.title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: unlocked ? AppTheme.primary : AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!large && !unlocked)
          SizedBox(
            width: size,
            child: Text(
              '${def.requiredDays}d',
              style: TextStyle(fontSize: 7.5.sp, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
      ],
    );
  }
}
