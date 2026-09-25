import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../model/tasks.dart';

@pragma('vm:entry-point')
Future<void> notificationTapBackground(
    NotificationResponse notificationResponse,
    ) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();

  try {
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  await NotificationServices._onNotificationResponse(notificationResponse);
}

class NotificationServices {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static final NotificationServices _instance =
  NotificationServices._internal();

  factory NotificationServices() {
    return _instance;
  }

  NotificationServices._internal();

  static const String _channelId = 'task_reminders';
  static const String _channelName = 'Task Reminders';
  static const String _completedAction = 'completed';
  static const String _snoozeAction = 'snooze';
  static const String _dismissAction = 'dismiss';

  static int notificationIdForTask(String taskId) {
    int hash = 2166136261;

    for (final byte in utf8.encode(taskId)) {
      hash ^= byte;
      hash = (hash * 16777619) & 0x7fffffff;
    }

    return hash == 0 ? 1 : hash;
  }

  static int snoozeNotificationId(String taskId) {
    final baseId = notificationIdForTask(taskId);

    return baseId ^ 0x40000000;
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
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

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
    await androidPlugin?.requestExactAlarmsPermission();
  }

  static Future<void> _onNotificationResponse(
      NotificationResponse response,
      ) async {
    final payload = response.payload;

    if (payload == null || payload.isEmpty) {
      return;
    }

    switch (response.actionId) {
      case _dismissAction:
        await _handleDismiss(response.id);
        break;

      case _snoozeAction:
        await _handleSnooze(payload, response.id);
        break;

      case _completedAction:
        await _handleCompleted(payload);
        break;
    }
  }

  static Future<void> _handleDismiss(int? notificationId) async {
    if (notificationId == null) {
      return;
    }

    await notificationsPlugin.cancel(notificationId);
  }

  static Future<void> _handleSnooze(
      String taskId,
      int? currentNotificationId,
      ) async {
    if (currentNotificationId != null) {
      await notificationsPlugin.cancel(currentNotificationId);
    }

    final snoozeId = snoozeNotificationId(taskId);

    await notificationsPlugin.cancel(snoozeId);

    final snoozeTime = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(minutes: 5));

    await notificationsPlugin.zonedSchedule(
      snoozeId,
      'Task Reminder',
      'Your task is still waiting for you',
      snoozeTime,
      _notificationDetails(taskId: taskId),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: taskId,
    );
  }

  static Future<void> _handleCompleted(String taskId) async {
    await cancelTaskNotification(taskId);

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc(taskId)
            .update({
          'isCompleted': true,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (_) {}
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

  Future<void> _scheduleOneTimeNotification(TaskModel task) async {
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
      payload: task.id,
    );
  }

  Future<void> _scheduleDailyNotification(TaskModel task) async {
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
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
      notificationIdForTask(task.id),
      task.title,
      'Your task is coming up',
      scheduledDate,
      _notificationDetails(taskId: task.id),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: task.id,
    );
  }

  Future<void> _scheduleWeeklyNotification(TaskModel task) async {
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
      _notificationDetails(taskId: task.id),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: task.id,
    );
  }

  Future<void> _scheduleCustomNotifications(TaskModel task) async {
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
        _notificationDetails(taskId: task.id),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: task.id,
      );
    }
  }

  tz.TZDateTime _nextWeekdayTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != weekday || !scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(taskId: payload),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  static NotificationDetails _notificationDetails({String? taskId}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound(
          'notif_english.wav'.split('.').first,
        ),
        icon: '@mipmap/ic_launcher',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            _completedAction,
            'Completed',
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            _snoozeAction,
            'Snooze 5 min',
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            _dismissAction,
            'Dismiss',
            showsUserInterface: false,
          ),
        ],
      ),
    );
  }

  static Future<void> cancelTaskNotification(String taskId) async {
    final notificationId =     notificationIdForTask(taskId);

    await notificationsPlugin.cancel(notificationId);

    final snoozeId = snoozeNotificationId(taskId);

    await notificationsPlugin.cancel(snoozeId);

    for (int i = 1; i <= 20; i++) {
      await notificationsPlugin.cancel(notificationId + i);
    }
  }
}