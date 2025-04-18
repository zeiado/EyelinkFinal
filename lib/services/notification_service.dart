import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/ringtone_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final RingtoneService _ringtoneService = RingtoneService();

  Future<void> initialize() async {
    await _ringtoneService.initialize();

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iOSSettings),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'incoming_calls',
      'Incoming Calls',
      description: 'Notifications for incoming calls',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showIncomingCallNotification({
    required String callId,
    required String userName,
    required String language,
  }) async {
    // Play ringtone
    await _ringtoneService.playRingtone();

    // Show notification
    await _localNotifications.show(
      DateTime.now().millisecond,
      'Incoming Call Request',
      '$userName needs assistance (Language: $language)',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'incoming_calls',
          'Incoming Calls',
          channelDescription: 'Notifications for incoming calls',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.call,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction('accept', 'Accept'),
            AndroidNotificationAction('decline', 'Decline'),
          ],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'incoming_call',
        ),
      ),
      payload: callId,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final String? callId = response.payload;
    if (callId != null) {
      if (response.actionId == 'accept') {
        _handleCallAccept(callId);
      } else if (response.actionId == 'decline') {
        _handleCallDecline(callId);
      }
    }
  }

  Future<void> _handleCallAccept(String callId) async {
    await _ringtoneService.stopRingtone();
    // Handle call acceptance logic
  }

  Future<void> _handleCallDecline(String callId) async {
    await _ringtoneService.stopRingtone();
    // Handle call decline logic
  }

  void dispose() {
    _ringtoneService.dispose();
  }
}