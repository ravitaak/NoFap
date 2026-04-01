import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gold gradient top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 320.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.goldDark.withOpacity(0.35),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.close, color: AppTheme.textMuted, size: 22.sp),
                      ),
                    ),
                  ),
                ),

                // Crown + title
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppTheme.goldGradient.createShader(b),
                          child: Icon(Icons.workspace_premium,
                              size: 72.sp, color: Colors.white),
                        ),
                        SizedBox(height: 12.h),
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppTheme.goldGradient.createShader(b),
                          child: Text(
                            'RISE PREMIUM',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Unlock your full potential.',
                          style: TextStyle(
                              fontSize: 14.sp, color: AppTheme.textSecondary),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'The serious warrior uses every tool.',
                          style: TextStyle(
                              fontSize: 12.sp, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 32.h)),

                // Features
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _FeatureRow(
                        icon: Icons.book_outlined,
                        title: 'Daily Journal',
                        description: 'Write unlimited private journal entries. Gold ink, your thoughts.',
                        color: AppTheme.primary,
                      ),
                      SizedBox(height: 10.h),
                      _FeatureRow(
                        icon: Icons.analytics_outlined,
                        title: 'Deep Insights',
                        description: 'Relapse pattern analysis, peak risk hours, trend graphs.',
                        color: const Color(0xFF60A5FA),
                      ),
                      SizedBox(height: 10.h),
                      _FeatureRow(
                        icon: Icons.self_improvement,
                        title: 'Unlimited Meditation',
                        description: 'All session durations. Guided tracks. Session history.',
                        color: const Color(0xFF818CF8),
                      ),
                      SizedBox(height: 10.h),
                      _FeatureRow(
                        icon: Icons.edit_note_outlined,
                        title: 'Custom Challenges',
                        description: 'Create your own daily challenges. Build your routine.',
                        color: const Color(0xFF34D399),
                      ),
                      SizedBox(height: 10.h),
                      _FeatureRow(
                        icon: Icons.block,
                        title: 'No Ads',
                        description: 'Pure, distraction-free experience. Focus only on your growth.',
                        color: AppTheme.statusDanger,
                      ),
                    ]),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 32.h)),

                // Plans
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _PlanCard(
                        title: 'Monthly',
                        price: '\$4.99',
                        period: 'per month',
                        featured: false,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _showPurchaseDialog(context, 'Monthly Plan', '\$4.99/month');
                        },
                      ),
                      SizedBox(height: 12.h),
                      _PlanCard(
                        title: 'Yearly — Best Value',
                        price: '\$24.99',
                        period: 'per year · Save 58%',
                        featured: true,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _showPurchaseDialog(context, 'Yearly Plan', '\$24.99/year');
                        },
                      ),
                      SizedBox(height: 12.h),
                      _PlanCard(
                        title: 'Lifetime',
                        price: '\$49.99',
                        period: 'one-time forever',
                        featured: false,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _showPurchaseDialog(context, 'Lifetime Plan', '\$49.99');
                        },
                      ),
                    ]),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Restore Purchase  ·  Terms  ·  Privacy',
                      style: TextStyle(
                          fontSize: 10.sp, color: AppTheme.textMuted),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 60.h)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, String plan, String price) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
        ),
        title: Text(
          plan,
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16.sp),
        ),
        content: Text(
          '$price\n\nThis will open the payment flow. '
          '(Implement your billing integration here.)',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13.sp)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('Subscribe',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title, description;
  final Color color;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, size: 20.sp, color: color),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: color, size: 18.sp),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title, price, period;
  final bool featured;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.featured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: featured ? AppTheme.goldGradient : null,
          color: featured ? null : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: featured
                ? Colors.transparent
                : AppTheme.primary.withOpacity(0.2),
            width: featured ? 0 : 1,
          ),
          boxShadow: featured
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: featured ? Colors.black : AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    period,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: featured
                          ? Colors.black.withOpacity(0.6)
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: featured ? Colors.black : AppTheme.primary,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: featured
                  ? Colors.black.withOpacity(0.6)
                  : AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
