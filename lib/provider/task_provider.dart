import 'package:flutter/foundation.dart';

import '../model/tasks.dart';
import '../services/notification_services.dart';
import '../services/task_firestore_service.dart';
import '../services/auth_services.dart';
import '../services/user_firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskFirestoreService taskFirestoreService;
  final AuthServices authServices;
  final UserFirestoreService userFirestoreService =
  UserFirestoreService();

  TaskProvider({
    required this.taskFirestoreService,
    required this.authServices,
  });

  List<TaskModel> _tasks = [];

  bool _isLoading = false;

  String? _error;

  List<TaskModel> get tasks => _tasks;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadTasks() async {
    final currentUser = authServices.currentUser;

    if (currentUser == null) return;

    try {
      _isLoading = true;
      _error = null;

      notifyListeners();

      final userTasks =
      await taskFirestoreService.getTasks(
        currentUser.uid,
      );

      _tasks = userTasks;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TaskModel?> addTask(
      TaskModel task,
      ) async {
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

      final taskId =
      await taskFirestoreService.addTask(
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
        repeat: task.repeat,
        repeatDays: task.repeatDays,
        remindBefore: task.remindBefore,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );

      _tasks.add(newTask);

      _tasks.sort(
            (a, b) =>
            a.scheduledAt.compareTo(b.scheduledAt),
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

  Future<void> toggleTask(
      TaskModel task,
      ) async {
    final currentUser = authServices.currentUser;

    if (currentUser == null) return;

    final newValue = !task.isCompleted;

    final index = _tasks.indexWhere(
          (element) => element.id == task.id,
    );

    if (index == -1) return;

    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      scheduledAt: task.scheduledAt,
      category: task.category,
      priority: task.priority,
      color: task.color,
      isCompleted: newValue,
      repeat: task.repeat,
      repeatDays: task.repeatDays,
      remindBefore: task.remindBefore,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(),
    );

    _tasks[index] = updatedTask;

    notifyListeners();

    try {
      await taskFirestoreService.updateTask(
        uid: currentUser.uid,
        taskId: task.id,
        data: {
          'isCompleted': newValue,
          'updatedAt': DateTime.now(),
        },
      );

      if (newValue) {
        await checkDailyStreak();
      }

      final notificationServices =
      NotificationServices();

      if (newValue) {
        await notificationServices
            .cancelTaskNotification(task.id);
      } else {
        await notificationServices
            .scheduleTaskNotification(updatedTask);
      }
    } catch (e) {
      _tasks[index] = task;

      _error = e.toString();

      notifyListeners();
    }
  }

  List<TaskModel> get todayTasks {
    final now = DateTime.now();

    return tasks.where((task) {
      return task.scheduledAt.year == now.year &&
          task.scheduledAt.month == now.month &&
          task.scheduledAt.day == now.day;
    }).toList();
  }

  Future<bool> updateTask(
      TaskModel task,
      ) async {
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

      await taskFirestoreService.updateTask(
        uid: currentUser.uid,
        taskId: task.id,
        data: {
          'title': task.title,
          'description': task.description,
          'scheduledAt': task.scheduledAt,
          'category': task.category,
          'priority': task.priority,
          'color': task.color,
          'isCompleted': task.isCompleted,
          'repeat': task.repeat,
          'repeatDays': task.repeatDays,
          'remindBefore': task.remindBefore,
          'updatedAt': DateTime.now(),
        },
      );

      final index = _tasks.indexWhere(
            (element) => element.id == task.id,
      );

      if (index != -1) {
        _tasks[index] = task;

        _tasks.sort(
              (a, b) =>
              a.scheduledAt.compareTo(b.scheduledAt),
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

  Future<bool> deleteTask(
      String taskId,
      ) async {
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

      _tasks.removeWhere(
            (task) => task.id == taskId,
      );

      await NotificationServices()
          .cancelTaskNotification(taskId);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkDailyStreak() async {
    final currentUser = authServices.currentUser;

    if (currentUser == null) return;

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final todayTasks = _tasks.where((task) {
      final date = task.scheduledAt;

      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();

    if (todayTasks.isEmpty) return;

    final allCompleted = todayTasks.every(
          (task) => task.isCompleted,
    );

    if (!allCompleted) return;

    final user =
    await userFirestoreService.getUser(
      currentUser.uid,
    );

    if (user == null) return;

    final lastDate = user.lastCompletedDate;

    if (lastDate != null) {
      final lastDay = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );

      if (lastDay == today) {
        return;
      }
    }

    int newStreak;

    if (lastDate == null) {
      newStreak = 1;
    } else {
      final lastDay = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );

      final difference =
          today.difference(lastDay).inDays;

      if (difference == 1) {
        newStreak =
            user.currentStreak + 1;
      } else {
        newStreak = 1;
      }
    }

    final newLongest =
    newStreak > user.longestStreak
        ? newStreak
        : user.longestStreak;

    await userFirestoreService.updateStreak(
      uid: currentUser.uid,
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastCompletedDate: today,
    );
  }

  List<TaskModel> tasksForDate(DateTime date) {
    final targetDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return _tasks.where((task) {
      final taskDate = DateTime(
        task.scheduledAt.year,
        task.scheduledAt.month,
        task.scheduledAt.day,
      );

      if (task.repeat == 'none') {
        return targetDate == taskDate;
      }

      if (targetDate.isBefore(taskDate)) {
        return false;
      }

      switch (task.repeat) {
        case 'daily':
          return true;

        case 'weekly':
          return targetDate.weekday == taskDate.weekday;

        case 'custom':
          return task.repeatDays.contains(targetDate.weekday);

        default:
          return targetDate == taskDate;
      }
    }).toList();
  }

  Set<DateTime> get taskDates {
    return _tasks.map((task) {
      final date = task.scheduledAt;

      return DateTime(
        date.year,
        date.month,
        date.day,
      );
    }).toSet();
  }
}