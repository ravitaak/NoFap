import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';
import 'package:nofap_reboot/bloc/streak_cubit.dart';
import 'package:nofap_reboot/router/app_router.dart';
import 'package:nofap_reboot/ui/widgets/achievement_badge.dart';
import 'package:nofap_reboot/ui/widgets/gold_glow_container.dart';
import 'package:url_launcher/url_launcher.dart';

class IdentityTab extends StatefulWidget {
  const IdentityTab({super.key});

  @override
  State<IdentityTab> createState() => _IdentityTabState();
}

class _IdentityTabState extends State<IdentityTab> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned(
                top: -40,
                right: -60,
                child: Container(
                  width: 220.w,
                  height: 220.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [AppTheme.primary.withOpacity(0.06), Colors.transparent]),
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
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Identity',
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
                                    'YOUR PROFILE',
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
                            const Spacer(),
                            // Avatar
                            Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
                                gradient: RadialGradient(colors: [AppTheme.primary.withOpacity(0.2), Colors.black]),
                              ),
                              child: Icon(Icons.person, color: AppTheme.primary, size: 24.sp),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Stats Summary ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: GoldGlowContainer(
                          padding: EdgeInsets.all(20.r),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ProfileStat(label: 'Current', value: '${state.currentStreakDays}d'),
                              ),
                              _Divider(),
                              Expanded(
                                child: _ProfileStat(label: 'Best', value: '${state.bestStreakDays}d'),
                              ),
                              _Divider(),
                              Expanded(
                                child: _ProfileStat(label: 'Relapses', value: '${state.totalRelapses}', valueColor: AppTheme.statusDanger),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                    // ── Achievements ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'ACHIEVEMENTS'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 90.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          separatorBuilder: (_, __) => SizedBox(width: 16.w),
                          itemCount: achievements.length,
                          itemBuilder: (ctx, i) {
                            final a = achievements[i];
                            return AchievementBadge(def: a, unlocked: state.bestStreakDays >= a.requiredDays, large: true);
                          },
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Why I Started ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'WHY I STARTED'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: GoldGlowContainer(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state.whyIStarted.isEmpty)
                                Text(
                                  'Tap to write your personal reason for quitting...',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppTheme.textMuted,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'Delius',
                                    height: 1.6,
                                  ),
                                )
                              else
                                Text(
                                  state.whyIStarted,
                                  style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary, height: 1.6, fontFamily: 'Delius'),
                                ),
                              SizedBox(height: 12.h),
                              GestureDetector(
                                onTap: () => _showEditReasonDialog(context, state.whyIStarted),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, size: 13.sp, color: AppTheme.primary),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Edit',
                                      style: TextStyle(fontSize: 12.sp, color: AppTheme.primary, fontWeight: FontWeight.w600, fontFamily: 'Delius'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    // ── Settings ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: _SectionLabel(label: 'SETTINGS'),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: GoldGlowContainer(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Column(
                            children: [
                              // _SettingsTile(
                              //   icon: Icons.notifications_outlined,
                              //   title: 'Daily Reminder',
                              //   trailing: Switch(
                              //     value: _notificationsEnabled,
                              //     activeThumbColor: AppTheme.primary,
                              //     onChanged: (v) {
                              //       setState(() => _notificationsEnabled = v);
                              //       Pref.notificationsEnabled = v;
                              //       HapticFeedback.lightImpact();
                              //     },
                              //   ),
                              // ),
                              // Divider(height: 1, color: AppTheme.surfaceBorder),
                              _SettingsTile(
                                icon: Icons.star_outline,
                                title: 'Rate App',
                                onTap: () => launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=org.codedrink.nofap_reboot')),
                              ),
                              Divider(height: 1, color: AppTheme.surfaceBorder),
                              _SettingsTile(
                                icon: Icons.apps_outlined,
                                title: 'More Apps',
                                onTap: () => launchUrl(Uri.parse('https://play.google.com/store/apps/developer?id=CodeDrink')),
                              ),
                              Divider(height: 1, color: AppTheme.surfaceBorder),
                              _SettingsTile(
                                icon: Icons.policy_outlined,
                                title: 'Privacy Policy',
                                onTap: () => AppRouter.navigateToPrivacyPolicy(context),
                              ),
                              Divider(height: 1, color: AppTheme.surfaceBorder),
                              Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
                                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                child: Text(
                                  'This app is not a medical or therapeutic solution. It is designed for productivity and habit tracking purposes only.',
                                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted, fontFamily: 'Delius'),
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

  void _showEditReasonDialog(BuildContext context, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.80),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
          ),
          title: Text(
            'Why I Started',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          content: TextField(
            controller: ctrl,
            maxLines: 4,
            autofocus: true,
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 13.sp, fontFamily: 'Delius'),
            decoration: InputDecoration(
              hintText: 'Write your personal reason...',
              hintStyle: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<StreakCubit>().updateWhyIStarted(ctrl.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

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
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 2.5, fontFamily: 'Delius'),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ProfileStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
          blendMode: valueColor != null ? BlendMode.dst : BlendMode.srcIn,
          child: Text(
            value,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: valueColor ?? Colors.white, fontFamily: 'Delius'),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted, fontFamily: 'Delius'),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40.h, color: AppTheme.surfaceBorder);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 20.sp, color: AppTheme.primary),
      title: Text(
        title,
        style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary, fontFamily: 'Delius'),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 13.sp, color: AppTheme.textMuted),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      minLeadingWidth: 24.w,
    );
  }
}
