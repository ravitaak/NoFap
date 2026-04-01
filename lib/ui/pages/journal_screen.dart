import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

// ── Simple in-memory journal store ──────────────────────────────────────────

class _JournalEntry {
  final DateTime date;
  String content;
  _JournalEntry({required this.date, required this.content});
}

final _journal = <_JournalEntry>[];

// ── JournalScreen ────────────────────────────────────────────────────────────

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TextEditingController _ctrl;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Ensure today's entry exists
    final today = _todayKey();
    if (_journal.isEmpty || !_isSameDay(_journal.last.date, today)) {
      _journal.insert(0, _JournalEntry(date: today, content: ''));
    }
    _ctrl = TextEditingController(text: _journal[_selectedIndex].content);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  DateTime _todayKey() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _saveCurrentEntry() {
    _journal[_selectedIndex].content = _ctrl.text;
  }

  void _selectEntry(int i) {
    _saveCurrentEntry();
    setState(() {
      _selectedIndex = i;
      _ctrl.text = _journal[i].content;
    });
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final isToday = _isSameDay(d, _todayKey());
    return isToday ? 'Today' : '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Ambient
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 260.w,
              height: 260.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.primary.withOpacity(0.06),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _saveCurrentEntry();
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 20.sp, color: AppTheme.primary),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (b) =>
                                AppTheme.goldGradient.createShader(b),
                            child: Text(
                              'Journal',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            'Write your warrior thoughts',
                            style: TextStyle(
                                fontSize: 11.sp, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _saveCurrentEntry,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: AppTheme.goldGradient,
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Row(
                    children: [
                      // Date sidebar
                      SizedBox(
                        width: 72.w,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount: _journal.length,
                          itemBuilder: (ctx, i) {
                            final selected = i == _selectedIndex;
                            final entry = _journal[i];
                            return GestureDetector(
                              onTap: () => _selectEntry(i),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.h, horizontal: 6.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  color: selected
                                      ? AppTheme.primary.withOpacity(0.15)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: selected
                                        ? AppTheme.primary.withOpacity(0.4)
                                        : Colors.white.withOpacity(0.06),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${entry.date.day}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w800,
                                        color: selected
                                            ? AppTheme.primary
                                            : AppTheme.textMuted,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(entry.date).split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 8.sp,
                                        color: selected
                                            ? AppTheme.primary
                                            : AppTheme.textMuted,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Container(
                                      width: 6.w,
                                      height: 6.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: entry.content.isNotEmpty
                                            ? AppTheme.statusSuccess
                                            : AppTheme.surfaceBorder,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1,
                        color: AppTheme.surfaceBorder,
                      ),

                      // Editor
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _focusNode.requestFocus(),
                          child: ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                              child: Container(
                                padding: EdgeInsets.all(20.r),
                                color: Colors.transparent,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        ShaderMask(
                                          shaderCallback: (b) =>
                                              AppTheme.goldGradient
                                                  .createShader(b),
                                          child: Text(
                                            '"',
                                            style: TextStyle(
                                              fontSize: 40.sp,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              height: 0.8,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          _formatDate(_journal[_selectedIndex].date),
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    Expanded(
                                      child: TextField(
                                        controller: _ctrl,
                                        focusNode: _focusNode,
                                        maxLines: null,
                                        expands: true,
                                        textAlignVertical: TextAlignVertical.top,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppTheme.textPrimary,
                                          height: 1.7,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText:
                                              'Write your thoughts, feelings, victories and struggles...\n\nThis is your private space.',
                                          hintStyle: TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 13.sp,
                                            height: 1.7,
                                          ),
                                        ),
                                        cursorColor: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
