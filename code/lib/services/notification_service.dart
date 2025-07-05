// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidInit),
    );
  }

  /// Schedule a daily reminder at the given [TimeOfDay].
  Future<void> scheduleDaily(TimeOfDay tod) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      tod.hour,
      tod.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      'Log your symptoms',
      'Tap to open Symptom Tracker',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          importance: Importance.high,
        ),
      ),
      // New required parameter replacing androidAllowWhileIdle:
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Removed the deprecated uiLocalNotificationDateInterpretation entirely
      // and now match only on the time component:
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
