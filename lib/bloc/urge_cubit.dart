import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

// ── Enums ──────────────────────────────────────────────────────────────────

enum UrgeTimerStatus { idle, running, done }

enum BreathPhase { inhale, hold, exhale }

// ── State ──────────────────────────────────────────────────────────────────

class UrgeState {
  final UrgeTimerStatus timerStatus;
  final int totalSeconds;
  final int remainingSeconds;
  final BreathPhase breathPhase;
  final bool breathingActive;

  const UrgeState({
    this.timerStatus = UrgeTimerStatus.idle,
    this.totalSeconds = 30,
    this.remainingSeconds = 30,
    this.breathPhase = BreathPhase.inhale,
    this.breathingActive = false,
  });

  double get timerProgress =>
      totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

  UrgeState copyWith({
    UrgeTimerStatus? timerStatus,
    int? totalSeconds,
    int? remainingSeconds,
    BreathPhase? breathPhase,
    bool? breathingActive,
  }) {
    return UrgeState(
      timerStatus: timerStatus ?? this.timerStatus,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      breathPhase: breathPhase ?? this.breathPhase,
      breathingActive: breathingActive ?? this.breathingActive,
    );
  }
}

// ── Cubit ──────────────────────────────────────────────────────────────────

class UrgeCubit extends Cubit<UrgeState> {
  Timer? _countdownTimer;
  Timer? _breathTimer;

  UrgeCubit() : super(const UrgeState());

  void startTimer(int seconds) {
    _countdownTimer?.cancel();
    emit(state.copyWith(
      timerStatus: UrgeTimerStatus.running,
      totalSeconds: seconds,
      remainingSeconds: seconds,
    ));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final remaining = state.remainingSeconds - 1;
      if (remaining <= 0) {
        t.cancel();
        emit(state.copyWith(
          timerStatus: UrgeTimerStatus.done,
          remainingSeconds: 0,
        ));
      } else {
        emit(state.copyWith(remainingSeconds: remaining));
      }
    });
  }

  void resetTimer() {
    _countdownTimer?.cancel();
    emit(state.copyWith(
      timerStatus: UrgeTimerStatus.idle,
      remainingSeconds: state.totalSeconds,
    ));
  }

  void startBreathing() {
    _breathTimer?.cancel();
    emit(state.copyWith(breathingActive: true, breathPhase: BreathPhase.inhale));
    _cycleBreathe();
  }

  void stopBreathing() {
    _breathTimer?.cancel();
    emit(state.copyWith(breathingActive: false, breathPhase: BreathPhase.inhale));
  }

  void _cycleBreathe() {
    // 4 sec inhale → 4 sec hold → 4 sec exhale → repeat
    const phases = [BreathPhase.inhale, BreathPhase.hold, BreathPhase.exhale];
    int phaseIdx = 0;

    _breathTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!state.breathingActive) return;
      phaseIdx = (phaseIdx + 1) % phases.length;
      emit(state.copyWith(breathPhase: phases[phaseIdx]));
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _breathTimer?.cancel();
    return super.close();
  }
}
