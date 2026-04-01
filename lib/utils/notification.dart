import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagingService {
  static String? fcmToken;

  static final MessagingService _instance = MessagingService._();

  factory MessagingService() => _instance;

  MessagingService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  initFirebaseNotificationChannel() {
    AwesomeNotifications().initialize('resource://drawable/ic_launcher', [
      NotificationChannel(
        channelKey: "app_updates",
        channelName: "Push Notifications",
        channelDescription: "Notification channel for app updates",
        channelShowBadge: false,
        locked: true,
        onlyAlertOnce: true,
        playSound: true,
        importance: NotificationImportance.Max,
        icon: 'resource://drawable/ic_launcher',
        defaultRingtoneType: DefaultRingtoneType.Notification,
      ),
    ]);
  }

  Future<void> init() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    initFirebaseNotificationChannel();

    debugPrint('User granted notifications permission: ${settings.authorizationStatus}');

    fcmToken = await _fcm.getToken();
    // log('fcmToken: $fcmToken');

    _fcm.setForegroundNotificationPresentationOptions(alert: true, badge: false, sound: true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.containsKey("screen")) {
        setData("screen", message.data["screen"]!);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data.containsKey("screen")) {
    setData("screen", message.data["screen"]!);
  }
}

void setData(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}
