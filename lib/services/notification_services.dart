import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
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

    tz.setLocalLocation(
      tz.getLocation(timezone),
    );
  } catch (_) {
    tz.setLocalLocation(
      tz.getLocation('UTC'),
    );
  }

  await NotificationServices._onNotificationResponse(
    notificationResponse,
  );
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

  static const String _completedAction = 'completed';
  static const String _snoozeAction = 'snooze';
  static const String _dismissAction = 'dismiss';

  static const String _defaultLanguageCode = 'en';

  static const int _birthdayBaseId = 2000000000;
  static const int _birthdayYearsToSchedule = 5;

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

  static int escalationNotificationId(
      String taskId,
      int level,
      ) {
    final baseId = notificationIdForTask(taskId);

    return baseId + 1000 + level;
  }

  static AppLocalizations _localizations(
      String? languageCode,
      ) {
    final code = languageCode == 'ar' ? 'ar' : 'en';

    return lookupAppLocalizations(
      Locale(code),
    );
  }

  static String _createPayload({
    required String taskId,
    required String languageCode,
    required String voiceGender,
  }) {
    return jsonEncode({
      'taskId': taskId,
      'languageCode': languageCode,
      'voiceGender': voiceGender,
    });
  }

  static Map<String, dynamic>? _parsePayload(
      String? payload,
      ) {
    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return {
        'taskId': payload,
        'languageCode': _defaultLanguageCode,
        'voiceGender': 'female',
      };
    }

    return null;
  }

  static String? _taskIdFromPayload(
      String? payload,
      ) {
    final data = _parsePayload(payload);

    return data?['taskId'] as String?;
  }

  static String _languageFromPayload(
      String? payload,
      ) {
    final data = _parsePayload(payload);

    final languageCode =
    data?['languageCode'] as String?;

    return languageCode == 'ar' ? 'ar' : 'en';
  }

  static String _voiceGenderFromPayload(
      String? payload,
      ) {
    final data = _parsePayload(payload);

    final voiceGender =
    data?['voiceGender'] as String?;

    return voiceGender == 'male' ? 'male' : 'female';
  }

  static String _getNotificationSound({
    required String languageCode,
    required String voiceGender,
  }) {
    final language = languageCode == 'ar' ? 'ar' : 'en';

    final gender =
    voiceGender == 'male' ? 'male' : 'female';

    return 'notif_${gender}_$language';
  }

  static String _getBirthdaySound({
    required String languageCode,
    required String voiceGender,
  }) {
    final language = languageCode == 'ar' ? 'ar' : 'en';

    final gender =
    voiceGender == 'male' ? 'male' : 'female';

    return 'hbd_${gender}_$language';
  }

  static Future<void> init() async {
    const androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings =
    InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
      _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
      notificationTapBackground,
    );

    tz.initializeTimeZones();

    try {
      final timezone =
      await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(
        tz.getLocation(timezone),
      );
    } catch (_) {
      tz.setLocalLocation(
        tz.getLocation('UTC'),
      );
    }

    await _requestPermission();
  }

  static Future<void> _requestPermission() async {
    final androidPlugin =
    notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

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
        await _handleDismiss(
          payload,
          response.id,
        );
        break;

      case _snoozeAction:
        await _handleSnooze(
          payload,
          response.id,
        );
        break;

      case _completedAction:
        await _handleCompleted(payload);
        break;
    }
  }

  static Future<void> _handleDismiss(
      String payload,
      int? notificationId,
      ) async {
    final taskId =
    _taskIdFromPayload(payload);

    if (taskId == null) {
      return;
    }

    if (notificationId != null) {
      await notificationsPlugin.cancel(
        notificationId,
      );
    }

    await cancelTaskNotification(taskId);
  }

  static Future<void> _handleSnooze(
      String payload,
      int? currentNotificationId,
      ) async {
    final taskId =
    _taskIdFromPayload(payload);

    if (taskId == null) {
      return;
    }

    final languageCode =
    _languageFromPayload(payload);

    final voiceGender =
    _voiceGenderFromPayload(payload);

    final l10n =
    _localizations(languageCode);

    if (currentNotificationId != null) {
      await notificationsPlugin.cancel(
        currentNotificationId,
      );
    }

    final snoozeId =
    snoozeNotificationId(taskId);

    await notificationsPlugin.cancel(
      snoozeId,
    );

    final snoozeTime =
    tz.TZDateTime.now(tz.local).add(
      const Duration(minutes: 5),
    );

    final newPayload = _createPayload(
      taskId: taskId,
      languageCode: languageCode,
      voiceGender: voiceGender,
    );

    await notificationsPlugin.zonedSchedule(
      snoozeId,
      l10n.notificationTaskReminders,
      l10n.notificationTaskStillWaiting,
      snoozeTime,
      _notificationDetails(
        taskId: taskId,
        languageCode: languageCode,
        voiceGender: voiceGender,
      ),
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
      payload: newPayload,
    );
  }

  static Future<void> _handleCompleted(
      String payload,
      ) async {
    final taskId =
    _taskIdFromPayload(payload);

    if (taskId == null) {
      return;
    }

    await cancelTaskNotification(taskId);

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      final user =
          FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc(taskId)
            .update({
          'isCompleted': true,
          'updatedAt':
          DateTime.now().toIso8601String(),
        });
      }
    } catch (_) {}
  }

  Future<void> scheduleTaskNotification(
      TaskModel task, {
        required String languageCode,
        required String voiceGender,
      }) async {
    if (task.isCompleted) {
      await cancelTaskNotification(task.id);
      return;
    }

    await cancelTaskNotification(task.id);

    switch (task.repeat) {
      case 'daily':
        await _scheduleDailyNotification(
          task,
          languageCode,
          voiceGender,
        );
        break;

      case 'weekly':
        await _scheduleWeeklyNotification(
          task,
          languageCode,
          voiceGender,
        );
        break;

      case 'custom':
        await _scheduleCustomNotifications(
          task,
          languageCode,
          voiceGender,
        );
        break;

      default:
        await _scheduleOneTimeNotification(
          task,
          languageCode,
          voiceGender,
        );
    }
  }

  Future<void> _scheduleOneTimeNotification(
      TaskModel task,
      String languageCode,
      String voiceGender,
      ) async {
    final reminderTime =
    task.scheduledAt.subtract(
      Duration(
        minutes: task.remindBefore,
      ),
    );

    if (!reminderTime.isAfter(
      DateTime.now(),
    )) {
      return;
    }

    await scheduleNotification(
      id: notificationIdForTask(task.id),
      title: task.title,
      body: _localizations(languageCode)
          .notificationTaskComingUp,
      dateTime: reminderTime,
      taskId: task.id,
      languageCode: languageCode,
      voiceGender: voiceGender,
    );

    await scheduleEscalationNotifications(
      task: task,
      reminderTime: reminderTime,
      languageCode: languageCode,
      voiceGender: voiceGender,
    );
  }

  Future<void> _scheduleDailyNotification(
      TaskModel task,
      String languageCode,
      String voiceGender,
      ) async {
    final reminderTime =
    task.scheduledAt.subtract(
      Duration(
        minutes: task.remindBefore,
      ),
    );

    final now =
    tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate =
          scheduledDate.add(
            const Duration(days: 1),
          );
    }

    final l10n =
    _localizations(languageCode);

    final payload = _createPayload(
      taskId: task.id,
      languageCode: languageCode,
      voiceGender: voiceGender,
    );

    await notificationsPlugin.zonedSchedule(
      notificationIdForTask(task.id),
      task.title,
      l10n.notificationTaskComingUp,
      scheduledDate,
      _notificationDetails(
        taskId: task.id,
        languageCode: languageCode,
        voiceGender: voiceGender,
      ),
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> _scheduleWeeklyNotification(
      TaskModel task,
      String languageCode,
      String voiceGender,
      ) async {
    final reminderTime =
    task.scheduledAt.subtract(
      Duration(
        minutes: task.remindBefore,
      ),
    );

    final scheduledDate =
    _nextWeekdayTime(
      reminderTime.weekday,
      reminderTime.hour,
      reminderTime.minute,
    );

    final l10n =
    _localizations(languageCode);

    final payload = _createPayload(
      taskId: task.id,
      languageCode: languageCode,
      voiceGender: voiceGender,
    );

    await notificationsPlugin.zonedSchedule(
      notificationIdForTask(task.id),
      task.title,
      l10n.notificationTaskComingUp,
      scheduledDate,
      _notificationDetails(
        taskId: task.id,
        languageCode: languageCode,
        voiceGender: voiceGender,
      ),
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  Future<void> _scheduleCustomNotifications(
      TaskModel task,
      String languageCode,
      String voiceGender,
      ) async {
    if (task.repeatDays.isEmpty) {
      return;
    }

    final reminderTime =
    task.scheduledAt.subtract(
      Duration(
        minutes: task.remindBefore,
      ),
    );

    final baseId =
    notificationIdForTask(task.id);

    final l10n =
    _localizations(languageCode);

    final payload = _createPayload(
      taskId: task.id,
      languageCode: languageCode,
      voiceGender: voiceGender,
    );

    for (
    int i = 0;
    i < task.repeatDays.length;
    i++
    ) {
      final weekday =
      task.repeatDays[i];

      final scheduledDate =
      _nextWeekdayTime(
        weekday,
        reminderTime.hour,
        reminderTime.minute,
      );

      await notificationsPlugin.zonedSchedule(
        baseId + i + 1,
        task.title,
        l10n.notificationTaskComingUp,
        scheduledDate,
        _notificationDetails(
          taskId: task.id,
          languageCode: languageCode,
          voiceGender: voiceGender,
        ),
        androidScheduleMode:
        AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
        DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
    }
  }

  tz.TZDateTime _nextWeekdayTime(
      int weekday,
      int hour,
      int minute,
      ) {
    final now =
    tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (
    scheduledDate.weekday != weekday ||
        !scheduledDate.isAfter(now)) {
      scheduledDate =
          scheduledDate.add(
            const Duration(days: 1),
          );
    }

    return scheduledDate;
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    required String taskId,
    required String languageCode,
    required String voiceGender,
  }) async {
    final scheduledDate =
    tz.TZDateTime.from(
      dateTime,
      tz.local,
    );

    final payload = _createPayload(
      taskId: taskId,
      languageCode: languageCode,
      voiceGender: voiceGender,
    );

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(
        taskId: taskId,
        languageCode: languageCode,
        voiceGender: voiceGender,
      ),
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  static NotificationDetails _notificationDetails({
    String? taskId,
    required String languageCode,
    required String voiceGender,
  }) {
    final l10n =
    _localizations(languageCode);

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'task_reminders_${languageCode}_$voiceGender',
        l10n.notificationTaskReminders,
        channelDescription:
        l10n.notificationTaskRemindersDescription,
        importance: Importance.high,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound(
          _getNotificationSound(
            languageCode: languageCode,
            voiceGender: voiceGender,
          ),
        ),
        icon: '@mipmap/ic_launcher',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            _completedAction,
            l10n.notificationCompleted,
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            _snoozeAction,
            l10n.notificationSnooze5Min,
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            _dismissAction,
            l10n.notificationDismiss,
            showsUserInterface: false,
          ),
        ],
      ),
    );
  }

  static Future<void> cancelTaskNotification(
      String taskId,
      ) async {
    final notificationId =
    notificationIdForTask(taskId);

    await notificationsPlugin.cancel(
      notificationId,
    );

    final snoozeId =
    snoozeNotificationId(taskId);

    await notificationsPlugin.cancel(
      snoozeId,
    );

    for (
    int level = 1;
    level <= 2;
    level++
    ) {
      await notificationsPlugin.cancel(
        escalationNotificationId(
          taskId,
          level,
        ),
      );
    }

    for (
    int i = 1;
    i <= 20;
    i++
    ) {
      await notificationsPlugin.cancel(
        notificationId + i,
      );
    }
  }

  static Future<void>
  scheduleEscalationNotifications({
    required TaskModel task,
    required DateTime reminderTime,
    required String languageCode,
    required String voiceGender,
  }) async {
    final firstEscalationTime =
    reminderTime.add(
      const Duration(minutes: 5),
    );

    final secondEscalationTime =
    reminderTime.add(
      const Duration(minutes: 15),
    );

    final firstId =
    escalationNotificationId(
      task.id,
      1,
    );

    final secondId =
    escalationNotificationId(
      task.id,
      2,
    );

    await notificationsPlugin.cancel(
      firstId,
    );

    await notificationsPlugin.cancel(
      secondId,
    );

    final now = DateTime.now();

    final l10n =
    _localizations(languageCode);

    if (firstEscalationTime.isAfter(now)) {
      await scheduleNotification(
        id: firstId,
        title: task.title,
        body: '${l10n.notificationDontForgetTask} ${task.title}',
        dateTime: firstEscalationTime,
        taskId: task.id,
        languageCode: languageCode,
        voiceGender: voiceGender,
      );
    }

    if (secondEscalationTime.isAfter(now)) {
      await scheduleNotification(
        id: secondId,
        title: task.title,
        body: '${l10n.notificationTaskStillWaiting} ${task.title}',
        dateTime: secondEscalationTime,
        taskId: task.id,
        languageCode: languageCode,
        voiceGender: voiceGender,
      );
    }
  }

  static Future<void> scheduleBirthdayNotifications({
    required int month,
    required int day,
    required String languageCode,
    required String voiceGender,
  }) async {
    await cancelBirthdayNotifications();

    final now =
    tz.TZDateTime.now(tz.local);

    final l10n =
    _localizations(languageCode);

    for (
    int yearOffset = 0;
    yearOffset < _birthdayYearsToSchedule;
    yearOffset++
    ) {
      final year =
          now.year + yearOffset;

      if (!_isValidDate(
        year,
        month,
        day,
      )) {
        continue;
      }

      final birthdayDate =
      tz.TZDateTime(
        tz.local,
        year,
        month,
        day,
        0,
        0,
      );

      if (!birthdayDate.isAfter(now)) {
        continue;
      }

      await notificationsPlugin.zonedSchedule(
        _birthdayBaseId + yearOffset,
        l10n.birthdayTodayTitle,
        l10n.birthdayTodayBody,
        birthdayDate,
        _birthdayNotificationDetails(
          languageCode: languageCode,
          voiceGender: voiceGender,
        ),
        androidScheduleMode:
        AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static bool _isValidDate(
      int year,
      int month,
      int day,
      ) {
    final date =
    DateTime(year, month, day);

    return date.year == year &&
        date.month == month &&
        date.day == day;
  }

  static NotificationDetails
  _birthdayNotificationDetails({
    required String languageCode,
    required String voiceGender,
  }) {
    final l10n =
    _localizations(languageCode);

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'birthday_${languageCode}_$voiceGender',
        l10n.birthdayNotificationChannel,
        channelDescription:
        l10n.birthdayNotificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound(
          _getBirthdaySound(
            languageCode: languageCode,
            voiceGender: voiceGender,
          ),
        ),
        icon: '@mipmap/ic_launcher',
      ),
    );
  }

  static Future<void>
  cancelBirthdayNotifications() async {
    for (
    int i = 0;
    i < _birthdayYearsToSchedule;
    i++
    ) {
      await notificationsPlugin.cancel(
        _birthdayBaseId + i,
      );
    }
  }
}