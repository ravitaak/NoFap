import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';
import 'package:nofap_reboot/ui/pages/tabs/ascend_tab.dart';
import 'package:nofap_reboot/ui/pages/tabs/command_tab.dart';
import 'package:nofap_reboot/ui/pages/tabs/forge_tab.dart';
import 'package:nofap_reboot/ui/pages/tabs/identity_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _activeIndex = 0;
  late PageController _pageCtrl;

  static const List<_TabMeta> _tabs = [
    _TabMeta(icon: Icons.bolt, label: 'Command'),
    _TabMeta(icon: Icons.trending_up, label: 'Ascend'),
    _TabMeta(icon: Icons.local_fire_department, label: 'Forge'),
    _TabMeta(icon: Icons.person, label: 'Identity'),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        final r = await InAppUpdate.startFlexibleUpdate();
        if (r == AppUpdateResult.success) await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int i) {
    if (_activeIndex == i) return;
    HapticFeedback.selectionClick();
    setState(() => _activeIndex = i);
    _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _goToForge() {
    _onNavTap(2);
  }

  Future<bool?> _showExitDialog() => showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.80),
    builder: (ctx) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              color: AppTheme.surfaceElevated,
              border: Border.all(color: AppTheme.primary.withOpacity(0.25), width: 1.2),
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.15), blurRadius: 40, spreadRadius: -4)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                    gradient: LinearGradient(
                      colors: [AppTheme.primary.withOpacity(0.12), AppTheme.primary.withOpacity(0.03)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border(bottom: BorderSide(color: AppTheme.primary.withOpacity(0.15))),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withOpacity(0.12),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.4), width: 1.5),
                          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 20)],
                        ),
                        child: Icon(Icons.military_tech, color: AppTheme.primary, size: 28.sp),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Stay Strong, Warrior.',
                        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, fontFamily: 'Delius'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                  child: Column(
                    children: [
                      Text(
                        'Every moment you stay committed is a victory.\n'
                        'Your streak continues to grow.',
                        style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, height: 1.6, fontFamily: 'Delius'),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.of(ctx).pop(true);
                                SystemNavigator.pop();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 13.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(color: AppTheme.surfaceBorder),
                                  color: AppTheme.surfaceBase,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Exit',
                                  style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary, fontFamily: 'Delius'),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () => Navigator.of(ctx).pop(false),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 13.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.r),
                                  gradient: AppTheme.goldGradient,
                                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Keep Going',
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black, fontFamily: 'Delius'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final btmPad = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) async => _showExitDialog(),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        body: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            CommandTab(onUrgePressed: _goToForge),
            const AscendTab(),
            const ForgeTab(),
            const IdentityTab(),
          ],
        ),
        // ── Bottom Nav ───────────────────────────────────
        bottomNavigationBar: _GoldBottomNav(activeIndex: _activeIndex, bottomInset: btmPad, tabs: _tabs, onTap: _onNavTap),
      ),
    );
  }
}

// ── Bottom Nav Bar ─────────────────────────────────────────────────────────

class _TabMeta {
  final IconData icon;
  final String label;
  const _TabMeta({required this.icon, required this.label});
}

class _GoldBottomNav extends StatelessWidget {
  final int activeIndex;
  final double bottomInset;
  final List<_TabMeta> tabs;
  final ValueChanged<int> onTap;

  const _GoldBottomNav({required this.activeIndex, required this.bottomInset, required this.tabs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final btmPad = bottomInset > 0 ? bottomInset : 8.h;
    const navH = 62.0;

    return Padding(
      padding: EdgeInsets.only(left: 14.w, right: 14.w, bottom: btmPad + 10.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(color: AppTheme.primary.withOpacity(0.18), blurRadius: 24, spreadRadius: -2, offset: const Offset(0, 2)),
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, spreadRadius: -6, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: navH.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                color: AppTheme.surfaceBase.withOpacity(0.92),
                border: Border.all(color: AppTheme.primary.withOpacity(0.18), width: 1.0),
              ),
              child: LayoutBuilder(
                builder: (_, cns) {
                  return Row(
                    children: List.generate(
                      tabs.length,
                      (i) => Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(i),
                          behavior: HitTestBehavior.opaque,
                          child: _NavItem(tab: tabs[i], isActive: i == activeIndex),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _TabMeta tab;
  final bool isActive;
  const _NavItem({required this.tab, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: isActive ? 1.18 : 1.0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          child: Icon(tab.icon, size: 21.sp, color: isActive ? AppTheme.primary : AppTheme.textMuted),
        ),
        SizedBox(height: 3.h),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: TextStyle(
            fontFamily: 'Delius',
            fontSize: 9.sp,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? AppTheme.primary : AppTheme.textMuted,
          ),
          child: Text(tab.label),
        ),
      ],
    );
  }
}
