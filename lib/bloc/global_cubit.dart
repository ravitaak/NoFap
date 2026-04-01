import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalState {
  ThemeMode themeMode;
  Locale locale;

  GlobalState({this.themeMode = ThemeMode.system, this.locale = const Locale('en')});

  GlobalState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return GlobalState(themeMode: themeMode ?? this.themeMode, locale: locale ?? this.locale);
  }
}

class GlobalCubit extends Cubit<GlobalState> {
  GlobalCubit(Locale locale) : super(GlobalState(locale: locale)) {
    initTheme();
  }

  void toggleTheme(bool isDarkMode) {
    emit(state.copyWith(themeMode: isDarkMode ? ThemeMode.light : ThemeMode.dark));
  }

  void initTheme() {
    var platformBrightness = PlatformDispatcher.instance.platformBrightness;
    if (platformBrightness == Brightness.dark) {
      emit(state.copyWith(themeMode: ThemeMode.dark));
    } else {
      emit(state.copyWith(themeMode: ThemeMode.light));
    }

    PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
      if (PlatformDispatcher.instance.platformBrightness == Brightness.dark) {
        emit(state.copyWith(themeMode: ThemeMode.dark));
      } else {
        emit(state.copyWith(themeMode: ThemeMode.light));
      }
    };
  }
}
