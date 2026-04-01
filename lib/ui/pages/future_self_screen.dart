import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

/// Future Self Reminder — user stores a personal message shown during urges.
class FutureSelfScreen extends StatefulWidget {
  const FutureSelfScreen({super.key});

  @override
  State<FutureSelfScreen> createState() => _FutureSelfScreenState();
}

class _FutureSelfScreenState extends State<FutureSelfScreen> {
  static String _savedMessage = '';
  bool _editing = false;
  late TextEditingController _ctrl;
  bool _showMessage = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _savedMessage);
    _showMessage = _savedMessage.isNotEmpty;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _prompts = [
    'Why did I start this journey?',
    'Who am I becoming?',
    'What will I lose if I fail?',
    'What do I gain by staying clean?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ambient gold glow
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250.w,
              height: 250.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.primary.withOpacity(0.07), Colors.transparent]),
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
                            decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(12.r)),
                            child: Icon(Icons.arrow_back_ios_new, color: AppTheme.textMuted, size: 16.sp),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🧬 FUTURE SELF', style: TextStyle(fontSize: 10.sp, color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.w700)),
                            Text('Your Personal Trigger', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                if (_showMessage && !_editing) ...[
                  // Show saved message in "urge mode"
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(24.r),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.r),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppTheme.primary.withOpacity(0.14), Colors.white.withOpacity(0.03)],
                              ),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                                  child: Text('"', style: TextStyle(fontSize: 60.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 0.8)),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  _savedMessage,
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, height: 1.6, fontStyle: FontStyle.italic),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                                Text('— Your future self', style: TextStyle(fontSize: 11.sp, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'This is you speaking to your weaker self.\nDon\'t let them down.',
                            style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted, height: 1.6),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: GestureDetector(
                        onTap: () { HapticFeedback.lightImpact(); setState(() => _editing = true); },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                            color: AppTheme.primary.withOpacity(0.06),
                          ),
                          alignment: Alignment.center,
                          child: Text('Edit My Message', style: TextStyle(fontSize: 14.sp, color: AppTheme.primary, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Writing prompts
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Write a message to show when urges hit.', style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted)),
                          SizedBox(height: 16.h),
                          Text('PROMPTS TO HELP YOU', style: TextStyle(fontSize: 9.sp, color: AppTheme.primary, letterSpacing: 2, fontWeight: FontWeight.w700)),
                          SizedBox(height: 10.h),
                          ..._prompts.map((p) => Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: Row(children: [
                              Icon(Icons.arrow_right, color: AppTheme.primary, size: 14.sp),
                              SizedBox(width: 4.w),
                              Text(p, style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary)),
                            ]),
                          )),
                          SizedBox(height: 20.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.r),
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
                            ),
                            child: TextField(
                              controller: _ctrl,
                              maxLines: 6,
                              style: TextStyle(fontSize: 14.sp, color: AppTheme.textPrimary, height: 1.6),
                              decoration: InputDecoration(
                                hintText: 'Write to your future self here...\n\n"Remember why you started. Don\'t give up."',
                                hintStyle: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted, height: 1.6),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          GestureDetector(
                            onTap: () {
                              if (_ctrl.text.trim().isEmpty) return;
                              HapticFeedback.heavyImpact();
                              setState(() { _FutureSelfScreenState._savedMessage = _ctrl.text.trim(); _showMessage = true; _editing = false; });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18.r),
                                gradient: AppTheme.goldGradient,
                                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20)],
                              ),
                              alignment: Alignment.center,
                              child: Text('SAVE MY MESSAGE', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
