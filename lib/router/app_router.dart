import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nofap_reboot/constants.dart';
import 'package:nofap_reboot/ui/pages/force_close_screen.dart';
import 'package:nofap_reboot/ui/pages/home_screen.dart';
import 'package:nofap_reboot/ui/pages/splash_screen.dart';

class AppRouter {
  static final remoteConfig = FirebaseRemoteConfig.instance;
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static bool shouldRedirectToForceClose() {
    try {
      RemoteConfigValue? rawDataFB = remoteConfig.getAll()['dialogData'];
      if (rawDataFB != null) {
        String data = rawDataFB.asString();
        Map<String, dynamic> rawData = jsonDecode(data);
        rawData["permanently"] = true;
        if (rawData["permanently"] ?? false) {
          int version = rawData["version"] ?? 0;
          if (version > Constants.appVersion) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic>? getDialogData() {
    try {
      RemoteConfigValue? rawDataFB = remoteConfig.getAll()['dialogData'];
      if (rawDataFB != null) {
        String data = rawDataFB.asString();
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static void navigateToHome(BuildContext context) {
    context.go('/');
  }

  static void navigateToSettings(BuildContext context) {
    context.go('/settings');
  }

  static void navigateToDonate(BuildContext context) {
    context.go('/donate');
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      if (shouldRedirectToForceClose() && state.fullPath != '/force-close') {
        return '/force-close';
      }
      return null;
    },
    observers: [FirebaseAnalyticsObserver(analytics: analytics)],
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen(), routes: [
     
        ],
      ),
      GoRoute(
        path: '/force-close',
        builder: (context, state) {
          final Map<String, dynamic> dialogData = getDialogData() ?? {};
          return PermanentlyStoppedScreen(dialogData: dialogData);
        },
      ),
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    ],
  );
}
