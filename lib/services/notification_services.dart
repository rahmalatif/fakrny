import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../model/tasks.dart';

class NotificationServices {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final NotificationServices _instance =
      NotificationServices._internal();

  factory NotificationServices() {
    return _instance;
  }

  static int notificationIdForTask(String taskId) {
    int hash = 2166136261;

    for (final byte in utf8.encode(taskId)) {
      hash ^= byte;
      hash = (hash * 16777619) & 0x7fffffff;
    }

    return hash == 0 ? 1 : hash;
  }

  NotificationServices._internal();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await notificationsPlugin.initialize(initializationSettings);

    // timezone
    tz.initializeTimeZones();

    final timezone = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timezone));

    await _requestPermission();
  }

  static Future<void> _requestPermission() async {
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> scheduleTaskNotification(TaskModel task) async {
    final reminderTime = task.scheduledAt.subtract(
      Duration(minutes: task.remindBefore),
    );

    final notificationId = notificationIdForTask(task.id);

    print('TASK ID: ${task.id}');
    print('NOTIFICATION ID: $notificationId');

    await scheduleNotification(
      id: notificationId,
      title: task.title,
      body: 'Your task is coming up',
      dateTime: reminderTime,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    final now = tz.TZDateTime.now(tz.local);

    print('==============================');
    print('NOTIFICATION ID: $id');
    print('TASK DATE: $dateTime');
    print('SCHEDULED DATE: $scheduledDate');
    print('NOW: $now');
    print('TIMEZONE: ${tz.local}');
    print('==============================');

    if (scheduledDate.isBefore(now)) {
      print('❌ NOTIFICATION TIME IS IN THE PAST');
      return;
    }

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    final pending = await notificationsPlugin.pendingNotificationRequests();

    print('==============================');
    print('PENDING NOTIFICATIONS:');

    for (final notification in pending) {
      print(
        'ID: ${notification.id} | '
        'TITLE: ${notification.title}',
      );
    }

    print('==============================');

    print('✅ NOTIFICATION SCHEDULED');
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
