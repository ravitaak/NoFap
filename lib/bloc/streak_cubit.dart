import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nofap_reboot/data/helper/database.dart';

// ── State ──────────────────────────────────────────────────────────────────

class StreakState {
  final DateTime? startDate;
  final List<DateTime> relapses;
  final String whyIStarted;

  const StreakState({
    this.startDate,
    this.relapses = const [],
    this.whyIStarted = '',
  });

  StreakState copyWith({
    DateTime? startDate,
    bool clearStartDate = false,
    List<DateTime>? relapses,
    String? whyIStarted,
  }) {
    return StreakState(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      relapses: relapses ?? this.relapses,
      whyIStarted: whyIStarted ?? this.whyIStarted,
    );
  }

  // ── Computed Properties ────────────────────────────────
  Duration get currentStreakDuration {
    if (startDate == null) return Duration.zero;
    return DateTime.now().difference(startDate!);
  }

  int get currentStreakDays => currentStreakDuration.inDays;
  int get currentStreakSeconds => currentStreakDuration.inSeconds % 60;

  Duration get bestStreakDuration {
    if (relapses.isEmpty && startDate != null) return currentStreakDuration;
    if (relapses.isEmpty) return Duration.zero;

    Duration best = Duration.zero;
    final sorted = List<DateTime>.from(relapses)..sort();

    // First streak (before first relapse — if no start or unknown)
    // We use installation time as fallback anchor (90 days ago)
    DateTime anchor =
        startDate != null && sorted.first.isAfter(startDate!)
            ? startDate!
            : sorted.first.subtract(const Duration(days: 1));

    for (int i = 0; i < sorted.length; i++) {
      final d = sorted[i].difference(anchor);
      if (d > best) best = d;
      anchor = sorted[i];
    }

    // Current ongoing streak after last relapse
    final current = DateTime.now().difference(sorted.last);
    if (current > best) best = current;

    return best;
  }

  int get bestStreakDays => bestStreakDuration.inDays;
  int get totalRelapses => relapses.length;

  String get timeLabel {
    if (startDate == null) return '0';
    final dur = currentStreakDuration;
    if (dur.inDays >= 1) return dur.inDays.toString();
    if (dur.inHours >= 1) return dur.inHours.toString();
    return dur.inMinutes.toString();
  }
}

// ── Cubit ──────────────────────────────────────────────────────────────────

class StreakCubit extends Cubit<StreakState> {
  Timer? _timer;

  StreakCubit()
      : super(
          StreakState(
            startDate: Pref.streakStartDate,
            relapses: Pref.relapses,
            whyIStarted: Pref.whyIStarted,
          ),
        ) {
    _startTick();
  }

  void _startTick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(state.copyWith());
    });
  }

  /// Start a new streak right now
  void startStreak() {
    final now = DateTime.now();
    Pref.streakStartDate = now;
    emit(state.copyWith(startDate: now));
  }

  /// Record a relapse — saves date and resets streak
  void relapse() {
    final now = DateTime.now();
    final updated = [...state.relapses, now];
    Pref.relapses = updated;
    Pref.streakStartDate = now;
    emit(state.copyWith(startDate: now, relapses: updated));
  }

  /// Update why I started
  void updateWhyIStarted(String reason) {
    Pref.whyIStarted = reason;
    emit(state.copyWith(whyIStarted: reason));
  }

  /// Force tick (for UI refresh)
  void tick() => emit(state.copyWith());

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
