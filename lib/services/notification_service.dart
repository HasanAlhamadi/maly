// 📁 lib/services/notification_service.dart
// PURPOSE: Local notifications — permissions, and the payment reminders that
// fire when a transaction's due date arrives.
//
// Android 13+ and iOS both require the user to grant permission before any
// notification can be shown, so init() asks for it.

import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Reminders are only scheduled once setup has succeeded.
  bool _ready = false;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);
    await _configureTimeZone();
    await _requestPermission();

    _ready = true;
  }

  /// zonedSchedule needs a real timezone database and the device's own zone,
  /// otherwise everything would be scheduled in UTC.
  Future<void> _configureTimeZone() async {
    tz_data.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      // Unknown zone name — fall back to UTC rather than failing setup.
    }
  }

  /// Without this, nothing is ever displayed on Android 13+ or iOS.
  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'debt_channel',
      'Payment reminders',
      channelDescription: 'Reminds you when a debt is due',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Schedules the reminder for one transaction.
  ///
  /// [id] is the transaction's own id, so cancelling or rescheduling later
  /// only needs that same number. A due date in the past is ignored.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime dueDate,
  }) async {
    if (!_ready) return;

    // Always replace whatever was scheduled for this transaction before.
    await cancelReminder(id);

    // Remind at 9am on the day it is due, which is more useful than midnight.
    final when = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      9,
    );

    if (!when.isAfter(tz.TZDateTime.now(tz.local))) return;

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: _details,
        // inexact still works when the user has not granted exact alarms.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // Scheduling is a convenience; never let it break saving a transaction.
    }
  }

  Future<void> cancelReminder(int id) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: id);
    } catch (_) {
      // Nothing was scheduled for this id.
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details,
    );
  }
}
