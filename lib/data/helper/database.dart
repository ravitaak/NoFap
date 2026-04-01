import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Pref {
  static late Box box;

  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    box = await Hive.openBox('data');
  }

  // ── Locale ─────────────────────────────────────────────
  static Locale get locale => Locale(box.get('locale') ?? 'en');
  static set locale(Locale v) => box.put('locale', v.languageCode);

  // ── App Review ─────────────────────────────────────────
  static bool get isAppReviewed => box.get('isAppReviewed') ?? false;
  static set isAppReviewed(bool v) => box.put('isAppReviewed', v);

  static DateTime? get appInstalledTime => box.get('appInstalledTime');
  static set appInstalledTime(DateTime? v) => box.put('appInstalledTime', v);

  // ── Streak ─────────────────────────────────────────────
  static DateTime? get streakStartDate {
    final raw = box.get('streakStartDate');
    if (raw == null) return null;
    return DateTime.tryParse(raw as String);
  }

  static set streakStartDate(DateTime? v) =>
      box.put('streakStartDate', v?.toIso8601String());

  static List<DateTime> get relapses {
    final raw = box.get('relapses');
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw as String);
    return list.map((e) => DateTime.parse(e as String)).toList();
  }

  static set relapses(List<DateTime> v) =>
      box.put('relapses', jsonEncode(v.map((e) => e.toIso8601String()).toList()));

  static String get whyIStarted => box.get('whyIStarted') ?? '';
  static set whyIStarted(String v) => box.put('whyIStarted', v);

  static bool get isPremium => box.get('isPremium') ?? false;
  static set isPremium(bool v) => box.put('isPremium', v);

  static bool get notificationsEnabled =>
      box.get('notificationsEnabled') ?? true;
  static set notificationsEnabled(bool v) =>
      box.put('notificationsEnabled', v);
}
