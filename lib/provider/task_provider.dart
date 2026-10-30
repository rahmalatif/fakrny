import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/tasks.dart';
import '../services/notification_services.dart';
import '../services/task_firestore_service.dart';
import '../services/auth_services.dart';
import '../services/user_firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskFirestoreService taskFirestoreService;
  final AuthServices authServices;
  final UserFirestoreService userFirestoreService;

  TaskProvider({
    required this.taskFirestoreService,
    required this.authServices,
    required this.userFirestoreService,
  });

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  Future<String> _getVoiceGender() async {
    final currentUser = authServices.currentUser;
    if (currentUser == null) return 'female';
    final user = await userFirestoreService.getUser(currentUser.uid);
    if (user == null) return 'female';
    return user.voiceGender == 'male' ? 'male' : 'female';
  }

  Future<void> loadTasks() async {
    final currentUser = authServices.currentUser;
    if (currentUser == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userTasks = await taskFirestoreService.getTasks(currentUser.uid);
      _tasks = userTasks;
      _tasks.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TaskModel?> addTask(
      TaskModel task, {
        required String languageCode,
      }) async {
    final currentUser = authServices.currentUser;
    if (currentUser == null) {
      _error = 'User is not logged in';
      notifyListeners();
      return null;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final taskId = await taskFirestoreService.addTask(
        uid: currentUser.uid,
        task: task,
      );

      final newTask = TaskModel(
        id: taskId,
        title: task.title,
        description: task.description,
        scheduledAt: task.scheduledAt,
        category: task.category,
        priority: task.priority,
        color: task.color,
        isCompleted: task.isCompleted,
        completedDates: List<String>.from(task.completedDates),
        repeat: task.repeat,
        repeatDays: List<int>.from(task.repeatDays),
        remindBefore: task.remindBefore,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
        repeatEndDate: task.repeatEndDate,
      );

      _tasks.add(newTask);
      _tasks.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      final voiceGender = await _getVoiceGender();
      await NotificationServices().scheduleTaskNotification(
        newTask,
        languageCode: languageCode,
        voiceGender: voiceGender,
      );

      return newTask;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isTaskCompletedOnDate(
      TaskModel task,
      DateTime date,
      ) {
    if (task.repeat == 'none') {
      return task.isCompleted;
    }
    return task.completedDates.contains(_dateKey(date));
  }

  bool _taskOccursOnDate(
      TaskModel task,
      DateTime date,
      ) {
    final targetDate = _normalizeDate(date);
    final startDate = _normalizeDate(task.scheduledAt);

    // إذا كان التاريخ المطلوب قبل بدء المهمة
    if (targetDate.isBefore(startDate)) {
      return false;
    }

    // إذا وُجد تاريخ نهاية للتكرار وتجاوزه التاريخ المطلوب
    if (task.repeatEndDate != null) {
      final endDate = _normalizeDate(task.repeatEndDate!);
      if (targetDate.isAfter(endDate)) {
        return false;
      }
    }

    switch (task.repeat.toLowerCase().trim()) {
      case 'none':
        return targetDate.isAtSameMomentAs(startDate);

      case 'daily':
        return true;

      case 'weekly':
        return targetDate.weekday == startDate.weekday;

      case 'monthly':
        final lastDayOfTargetMonth =
        _daysInMonth(targetDate.year, targetDate.month);
        if (startDate.day > lastDayOfTargetMonth) {
          return targetDate.day == lastDayOfTargetMonth;
        }
        return targetDate.day == startDate.day;

      case 'custom':
        return task.repeatDays.contains(targetDate.weekday);

      default:
        return targetDate.isAtSameMomentAs(startDate);
    }
  }

  List<TaskModel> tasksForDate(DateTime date) {
    final result = _tasks.where(
          (task) => _taskOccursOnDate(task, date),
    ).toList();

    result.sort(
          (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
    );

    return result;
  }

  List<TaskModel> get todayTasks => tasksForDate(DateTime.now());

  Future<void> toggleTask(
      TaskModel task, {
        required String languageCode,
        DateTime? targetDate,
      }) async {
    final currentUser = authServices.currentUser;
    if (currentUser == null) return;

    final index = _tasks.indexWhere((element) => element.id == task.id);
    if (index == -1) return;

    final currentTask = _tasks[index];
    final selectedDate = _normalizeDate(targetDate ?? DateTime.now());
    final now = DateTime.now();

    if (currentTask.repeat == 'none') {
      final newValue = !currentTask.isCompleted;

      final updatedTask = TaskModel(
        id: currentTask.id,
        title: currentTask.title,
        description: currentTask.description,
        scheduledAt: currentTask.scheduledAt,
        category: currentTask.category,
        priority: currentTask.priority,
        color: currentTask.color,
        isCompleted: newValue,
        completedDates: List<String>.from(currentTask.completedDates),
        repeat: currentTask.repeat,
        repeatDays: List<int>.from(currentTask.repeatDays),
        remindBefore: currentTask.remindBefore,
        createdAt: currentTask.createdAt,
        updatedAt: now,
        repeatEndDate: currentTask.repeatEndDate,
      );

      _tasks[index] = updatedTask;
      _error = null;
      notifyListeners();

      try {
        await taskFirestoreService.updateTask(
          uid: currentUser.uid,
          taskId: currentTask.id,
          data: {
            'isCompleted': newValue,
            'updatedAt': now,
          },
        );

        if (newValue) {
          await checkDailyStreak();
          await NotificationServices.cancelTaskNotification(currentTask.id);
        } else {
          final voiceGender = await _getVoiceGender();
          await NotificationServices().scheduleTaskNotification(
            updatedTask,
            languageCode: languageCode,
            voiceGender: voiceGender,
          );
        }
      } catch (e) {
        _tasks[index] = currentTask;
        _error = e.toString();
        notifyListeners();
      }

      return;
    }

    final completedDates = List<String>.from(currentTask.completedDates);
    final dateKey = _dateKey(selectedDate);
    final wasCompleted = completedDates.contains(dateKey);

    if (wasCompleted) {
      completedDates.remove(dateKey);
    } else {
      completedDates.add(dateKey);
    }

    final updatedTask = TaskModel(
      id: currentTask.id,
      title: currentTask.title,
      description: currentTask.description,
      scheduledAt: currentTask.scheduledAt,
      category: currentTask.category,
      priority: currentTask.priority,
      color: currentTask.color,
      isCompleted: false,
      completedDates: completedDates,
      repeat: currentTask.repeat,
      repeatDays: List<int>.from(currentTask.repeatDays),
      remindBefore: currentTask.remindBefore,
      createdAt: currentTask.createdAt,
      updatedAt: now,
      repeatEndDate: currentTask.repeatEndDate,
    );

    _tasks[index] = updatedTask;
    _error = null;
    notifyListeners();

    try {
      await taskFirestoreService.updateTask(
        uid: currentUser.uid,
        taskId: currentTask.id,
        data: {
          'completedDates': completedDates,
          'updatedAt': now,
        },
      );

      if (!wasCompleted) {
        await checkDailyStreak();
      }
    } catch (e) {
      _tasks[index] = currentTask;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateTask(
      TaskModel task, {
        required String languageCode,
      }) async {
    final currentUser = authServices.currentUser;
    if (currentUser == null) {
      _error = 'User is not logged in';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final index = _tasks.indexWhere((element) => element.id == task.id);
      final existingTask = index == -1 ? null : _tasks[index];

      final updatedTask = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        scheduledAt: task.scheduledAt,
        category: task.category,
        priority: task.priority,
        color: task.color,
        isCompleted: task.isCompleted,
        completedDates: List<String>.from(
          existingTask?.completedDates ?? task.completedDates,
        ),
        repeat: task.repeat,
        repeatDays: List<int>.from(task.repeatDays),
        remindBefore: task.remindBefore,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
        repeatEndDate: task.repeatEndDate,
      );

      await taskFirestoreService.updateTask(
        uid: currentUser.uid,
        taskId: task.id,
        data: {
          'title': updatedTask.title,
          'description': updatedTask.description,
          'scheduledAt': updatedTask.scheduledAt,
          'category': updatedTask.category,
          'priority': updatedTask.priority,
          'color': updatedTask.color,
          'isCompleted': updatedTask.isCompleted,
          'repeat': updatedTask.repeat,
          'repeatDays': updatedTask.repeatDays,
          'remindBefore': updatedTask.remindBefore,
          'updatedAt': updatedTask.updatedAt,
          'repeatEndDate': updatedTask.repeatEndDate != null
              ? Timestamp.fromDate(updatedTask.repeatEndDate!)
              : null,
        },
      );

      if (index != -1) {
        _tasks[index] = updatedTask;
        _tasks.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      }

      if (updatedTask.repeat == 'none' && updatedTask.isCompleted) {
        await NotificationServices.cancelTaskNotification(updatedTask.id);
      } else {
        final voiceGender = await _getVoiceGender();
        await NotificationServices().scheduleTaskNotification(
          updatedTask,
          languageCode: languageCode,
          voiceGender: voiceGender,
        );
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTask(String taskId) async {
    final currentUser = authServices.currentUser;
    if (currentUser == null) {
      _error = 'User is not logged in';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await taskFirestoreService.deleteTask(
        uid: currentUser.uid,
        taskId: taskId,
      );

      _tasks.removeWhere((task) => task.id == taskId);
      await NotificationServices.cancelTaskNotification(taskId);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rescheduleAllNotifications({
    required String languageCode,
  }) async {
    final voiceGender = await _getVoiceGender();

    for (final task in _tasks) {
      if (task.repeat == 'none' && task.isCompleted) {
        await NotificationServices.cancelTaskNotification(task.id);
      } else {
        await NotificationServices().scheduleTaskNotification(
          task,
          languageCode: languageCode,
          voiceGender: voiceGender,
        );
      }
    }
  }

  Future<void> checkDailyStreak() async {
    final currentUser = authServices.currentUser;
    if (currentUser == null) return;

    final today = _normalizeDate(DateTime.now());
    final dueToday = tasksForDate(today);

    if (dueToday.isEmpty) return;

    final allCompleted = dueToday.every(
          (task) => isTaskCompletedOnDate(task, today),
    );

    if (!allCompleted) return;

    final user = await userFirestoreService.getUser(currentUser.uid);
    if (user == null) return;

    final lastDate = user.lastCompletedDate;
    if (lastDate != null) {
      final lastDay = _normalizeDate(lastDate);
      if (lastDay == today) return;
    }

    int newStreak;
    if (lastDate == null) {
      newStreak = 1;
    } else {
      final lastDay = _normalizeDate(lastDate);
      final difference = today.difference(lastDay).inDays;
      newStreak = difference == 1 ? user.currentStreak + 1 : 1;
    }

    final newLongest =
    newStreak > user.longestStreak ? newStreak : user.longestStreak;

    await userFirestoreService.updateStreak(
      uid: currentUser.uid,
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastCompletedDate: today,
    );
  }

  Set<DateTime> get taskDates {
    final dates = <DateTime>{};

    for (final task in _tasks) {
      final startDate = _normalizeDate(task.scheduledAt);

      if (task.repeat == 'none') {
        dates.add(startDate);
        continue;
      }

      for (int i = 0; i < 365; i++) {
        final date = startDate.add(Duration(days: i));
        if (_taskOccursOnDate(task, date)) {
          dates.add(date);
        }
      }
    }

    return dates;
  }
}