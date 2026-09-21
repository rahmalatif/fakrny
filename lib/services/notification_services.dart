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

  NotificationServices._internal();

  static int notificationIdForTask(String taskId) {
    int hash = 2166136261;

    for (final byte in utf8.encode(taskId)) {
      hash ^= byte;
      hash = (hash * 16777619) & 0x7fffffff;
    }

    return hash == 0 ? 1 : hash;
  }

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
    );

    tz.initializeTimeZones();

    final timezone = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(timezone),
    );

    await _requestPermission();
  }

  static Future<void> _requestPermission() async {
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> scheduleTaskNotification(TaskModel task) async {
    if (task.isCompleted) {
      await cancelTaskNotification(task.id);
      return;
    }

    await cancelTaskNotification(task.id);

    switch (task.repeat) {
      case 'daily':
        await _scheduleDailyNotification(task);
        break;

      case 'weekly':
        await _scheduleWeeklyNotification(task);
        break;

      case 'custom':
        await _scheduleCustomNotifications(task);
        break;

      default:
        await _scheduleOneTimeNotification(task);
    }
  }

  Future<void> _scheduleOneTimeNotification(
      TaskModel task,
      ) async {
    final reminderTime = task.scheduledAt.subtract(
      Duration(minutes: task.remindBefore),
    );

    if (!reminderTime.isAfter(DateTime.now())) {
      return;
    }

    await scheduleNotification(
      id: notificationIdForTask(task.id),
      title: task.title,
      body: 'Your task is coming up',
      dateTime: reminderTime,
    );
  }

  Future<void> _scheduleDailyNotification(
      TaskModel task,
      ) async {
    final reminderTime = task.scheduledAt.subtract(
      Duration(minutes: task.remindBefore),
    );

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(
        const Duration(days: 1),
      );
    }

    await notificationsPlugin.zonedSchedule(
      notificationIdForTask(task.id),
      task.title,
      'Your task is coming up',
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWeeklyNotification(
      TaskModel task,
      ) async {
    final reminderTime = task.scheduledAt.subtract(
      Duration(minutes: task.remindBefore),
    );

    final scheduledDate = _nextWeekdayTime(
      reminderTime.weekday,
      reminderTime.hour,
      reminderTime.minute,
    );

    await notificationsPlugin.zonedSchedule(
      notificationIdForTask(task.id),
      task.title,
      'Your task is coming up',
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> _scheduleCustomNotifications(
      TaskModel task,
      ) async {
    if (task.repeatDays.isEmpty) {
      return;
    }

    final reminderTime = task.scheduledAt.subtract(
      Duration(minutes: task.remindBefore),
    );

    final baseId = notificationIdForTask(task.id);

    for (int i = 0; i < task.repeatDays.length; i++) {
      final weekday = task.repeatDays[i];

      final scheduledDate = _nextWeekdayTime(
        weekday,
        reminderTime.hour,
        reminderTime.minute,
      );

      await notificationsPlugin.zonedSchedule(
        baseId + i + 1,
        task.title,
        'Your task is coming up',
        scheduledDate,
        _notificationDetails(),
        androidScheduleMode:
        AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
        DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _nextWeekdayTime(
      int weekday,
      int hour,
      int minute,
      ) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != weekday ||
        !scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(
        const Duration(days: 1),
      );
    }

    return scheduledDate;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      dateTime,
      tz.local,
    );

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_reminders',
        'Task Reminders',
        channelDescription:
        'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
  }

  Future<void> cancelTaskNotification(
      String taskId,
      ) async {
    final notificationId =
    notificationIdForTask(taskId);

    await notificationsPlugin.cancel(
      notificationId,
    );

    for (int i = 1; i <= 20; i++) {
      await notificationsPlugin.cancel(
        notificationId + i,
      );
    }
  }
}