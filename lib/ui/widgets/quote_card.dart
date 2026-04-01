import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

const List<String> motivationalQuotes = [
  '"Discipline is the bridge between goals and accomplishment." — Jim Rohn',
  '"The secret of your future is hidden in your daily routine." — Mike Murdock',
  '"Strength does not come from physical capacity. It comes from an indomitable will." — Gandhi',
  '"You have power over your mind, not outside events. Realize this, and you will find strength." — Marcus Aurelius',
  '"Conquer yourself rather than the world." — René Descartes',
  '"The will of a man is his happiness." — Friedrich Schiller',
  '"Self-control is the chief element in self-respect." — Thucydides',
  '"Every great man, every successful man, no matter what the field of endeavor, has known the magic of enthusiasm." — Norman Vincent Peale',
  '"Mastering others is strength. Mastering yourself is true power." — Lao Tzu',
  '"The first and greatest victory is to conquer yourself." — Plato',
  '"You are the master of your destiny. You can influence, direct and control your own environment." — Napoleon Hill',
  '"Pain is temporary. Quitting lasts forever." — Lance Armstrong',
  '"The mind is everything. What you think you become." — Buddha',
  '"He who conquers himself is the mightiest warrior." — Confucius',
];

class QuoteCard extends StatelessWidget {
  final int dayIndex;

  const QuoteCard({super.key, required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    final quote = motivationalQuotes[dayIndex % motivationalQuotes.length];
    // Split author if present
    final parts = quote.split(' — ');
    final text = parts[0].replaceAll('"', '').replaceAll('"', '').replaceAll('"', '');
    final author = parts.length > 1 ? parts[1] : null;

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surfaceBase,
            AppTheme.surfaceElevated,
          ],
        ),
        border: Border.all(color: AppTheme.primary.withOpacity(0.20), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold quote mark
          ShaderMask(
            shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
            child: Text(
              '\u201C',
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 0.8,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: AppTheme.textPrimary,
              fontStyle: FontStyle.italic,
              height: 1.6,
              fontFamily: 'Delius',
            ),
          ),
          if (author != null) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Container(
                  width: 24.w,
                  height: 1.5,
                  color: AppTheme.primary.withOpacity(0.5),
                ),
                SizedBox(width: 8.w),
                Text(
                  author,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontFamily: 'Delius',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
