import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'logging_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final LoggingService _log = LoggingService();

  String? _fcmToken;

  Future<void> initialize() async {
    if (kIsWeb) {
      _log.info('FCM not supported on web, skipping', tag: 'NotificationService');
      return;
    }
    try {
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          ),
        ),
      );
    } catch (e) {
      _log.warn('Local notifications init failed: $e', tag: 'NotificationService');
    }

    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _fcmToken = await _fcm.getToken();
        _log.info('FCM token obtained', tag: 'NotificationService');
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    } catch (e) {
      _log.warn('FCM init failed (expected on local web): $e', tag: 'NotificationService');
    }
  }

  String? get fcmToken => _fcmToken;

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      try {
        await _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'youshe_orders',
              'Youshe Orders',
              channelDescription: 'Order notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: message.data['route'],
        );
      } catch (e) {
        _log.warn('Local notification show failed: $e', tag: 'NotificationService');
      }
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    LoggingService().info('Background message received', tag: 'NotificationService');
  }

  Future<void> deleteToken() async {
    try {
      await _fcm.deleteToken();
      _log.info('FCM token deleted', tag: 'NotificationService');
    } catch (e) {
      _log.warn('FCM deleteToken failed: $e', tag: 'NotificationService');
    }
  }
}
