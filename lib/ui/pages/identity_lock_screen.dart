import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

class IdentityLockScreen extends StatefulWidget {
  const IdentityLockScreen({super.key});
  @override
  State<IdentityLockScreen> createState() => _IdentityLockScreenState();
}

class _IdentityLockScreenState extends State<IdentityLockScreen>
    with SingleTickerProviderStateMixin {
  static int _selectedIdentity = 0;
  bool _showUrgeMode = false;
  late AnimationController _pulseCtrl;

  static const _identities = [
    (emoji: '🦁', title: 'The Disciplined', statement: 'I am disciplined. I choose long-term power over instant pleasure.', color: Color(0xFFD4AF37)),
    (emoji: '⚔️', title: 'The Warrior', statement: 'I am a warrior. Warriors don\'t surrender to weakness.', color: Color(0xFFEF4444)),
    (emoji: '🧠', title: 'The Master', statement: 'I am the master of my mind. My thoughts obey me.', color: Color(0xFF818CF8)),
    (emoji: '🔥', title: 'The Builder', statement: 'I am building something great. I protect my energy fiercely.', color: Color(0xFFF59E0B)),
    (emoji: '👑', title: 'The King', statement: 'I carry myself like royalty. Kings don\'t chase cheap highs.', color: Color(0xFFD4AF37)),
    (emoji: '🌊', title: 'The Unshakeable', statement: 'I am unshakeable. No urge has power over my identity.', color: Color(0xFF38BDF8)),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final identity = _identities[_selectedIdentity];
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
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
                      child: Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.arrow_back_ios_new, color: AppTheme.textMuted, size: 16.sp)),
                    ),
                    SizedBox(width: 14.w),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('🧬 IDENTITY LOCK', style: TextStyle(fontSize: 10.sp, color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.w700)),
                      Text('Who you are becoming', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                    ]),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),

            if (_showUrgeMode) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Container(
                      padding: EdgeInsets.all(28.r),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [identity.color.withOpacity(0.15 + 0.05 * _pulseCtrl.value), Colors.black],
                        ),
                        border: Border.all(color: identity.color.withOpacity(0.4 + 0.2 * _pulseCtrl.value), width: 1.5),
                        boxShadow: [BoxShadow(color: identity.color.withOpacity(0.2 * _pulseCtrl.value), blurRadius: 32)],
                      ),
                      child: Column(children: [
                        Text(identity.emoji, style: TextStyle(fontSize: 52.sp)),
                        SizedBox(height: 16.h),
                        Text('STOP.', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: identity.color, letterSpacing: 3)),
                        SizedBox(height: 8.h),
                        Text('This action doesn\'t match who you are.', style: TextStyle(fontSize: 15.sp, color: AppTheme.textSecondary, height: 1.5), textAlign: TextAlign.center),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r), color: Colors.white.withOpacity(0.04), border: Border.all(color: identity.color.withOpacity(0.2))),
                          child: Text('"${identity.statement}"', style: TextStyle(fontSize: 14.sp, color: AppTheme.textPrimary, fontStyle: FontStyle.italic, height: 1.6), textAlign: TextAlign.center),
                        ),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () { HapticFeedback.heavyImpact(); setState(() => _showUrgeMode = false); Navigator.pop(context); },
                          child: Container(
                            width: double.infinity, padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r), gradient: AppTheme.goldGradient, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20)]),
                            alignment: Alignment.center,
                            child: Text('I CHOOSE MY IDENTITY', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5)),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Identity selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WHO ARE YOU BECOMING?', style: TextStyle(fontSize: 9.sp, color: AppTheme.primary, letterSpacing: 2.5, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4.h),
                      Text('Choose your identity. The app will remind you during urges.', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h, childAspectRatio: 1.5),
                  delegate: SliverChildBuilderDelegate((_, i) {
                    final id = _identities[i];
                    final selected = i == _selectedIdentity;
                    return GestureDetector(
                      onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedIdentity = i); },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.r),
                          color: selected ? id.color.withOpacity(0.12) : Colors.white.withOpacity(0.03),
                          border: Border.all(color: selected ? id.color.withOpacity(0.5) : Colors.white.withOpacity(0.08), width: selected ? 1.5 : 1),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(id.emoji, style: TextStyle(fontSize: 20.sp)),
                            const Spacer(),
                            if (selected) Container(width: 8.w, height: 8.w, decoration: BoxDecoration(shape: BoxShape.circle, color: id.color)),
                          ]),
                          const Spacer(),
                          Text(id.title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: selected ? id.color : AppTheme.textPrimary)),
                        ]),
                      ),
                    );
                  }, childCount: _identities.length),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),

              // Selected identity statement preview
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    padding: EdgeInsets.all(18.r),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r), color: identity.color.withOpacity(0.07), border: Border.all(color: identity.color.withOpacity(0.2))),
                    child: Row(children: [
                      Text(identity.emoji, style: TextStyle(fontSize: 24.sp)),
                      SizedBox(width: 12.w),
                      Expanded(child: Text('"${identity.statement}"', style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary, fontStyle: FontStyle.italic, height: 1.5))),
                    ]),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),

              // Test urge mode
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: GestureDetector(
                    onTap: () { HapticFeedback.lightImpact(); setState(() => _showUrgeMode = true); },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r), border: Border.all(color: identity.color.withOpacity(0.4)), color: identity.color.withOpacity(0.08)),
                      alignment: Alignment.center,
                      child: Text('PREVIEW URGE LOCK SCREEN', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: identity.color, letterSpacing: 1)),
                    ),
                  ),
                ),
              ),
            ],

            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }
}
