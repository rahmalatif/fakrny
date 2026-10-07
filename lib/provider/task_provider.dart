import 'package:flutter/cupertino.dart';
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

  Future<String> _getVoiceGender() async {
    final currentUser = authServices.currentUser;

    if (currentUser == null) {
      return 'female';
    }

    final user = await userFirestoreService.getUser(
      currentUser.uid,
    );

    if (user == null) {
      return 'female';
    }

    return user.voiceGender == 'male'
        ? 'male'
        : 'female';
  }

  Future<void> loadTasks() async {
    final currentUser = authServices.currentUser;

    if (currentUser == null) return;

    try {
      _isLoading = true;
      _error = null;

      notifyListeners();

      final userTasks = await taskFirestoreService.getTasks(
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
        repeat: task.repeat,
        repeatDays: task.repeatDays,
        remindBefore: task.remindBefore,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );

      _tasks.add(newTask);

      _tasks.sort(
            (a, b) => a.scheduledAt.compareTo(
          b.scheduledAt,
        ),
      );

      final voiceGender = await _getVoiceGender();

      await NotificationServices()
          .scheduleTaskNotification(
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

  Future<void> toggleTask(
      TaskModel task, {
        required String languageCode,
      }) async {
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

        await NotificationServices.cancelTaskNotification(
          task.id,
        );
      } else {
        final voiceGender = await _getVoiceGender();

        await NotificationServices()
            .scheduleTaskNotification(
          updatedTask,
          languageCode: languageCode,
          voiceGender: voiceGender,
        );
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
              (a, b) => a.scheduledAt.compareTo(
            b.scheduledAt,
          ),
        );
      }

      if (task.isCompleted) {
        await NotificationServices.cancelTaskNotification(
          task.id,
        );
      } else {
        final voiceGender = await _getVoiceGender();

        await NotificationServices()
            .scheduleTaskNotification(
          task,
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

      _tasks.removeWhere(
            (task) => task.id == taskId,
      );

      await NotificationServices.cancelTaskNotification(
        taskId,
      );

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
      if (task.isCompleted) {
        await NotificationServices.cancelTaskNotification(
          task.id,
        );
      } else {
        await NotificationServices()
            .scheduleTaskNotification(
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

    final user = await userFirestoreService.getUser(
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
          return targetDate.weekday ==
              taskDate.weekday;

        case 'custom':
          return task.repeatDays.contains(
            targetDate.weekday,
          );

        default:
          return targetDate == taskDate;
      }
    }).toList();
  }

  Set<DateTime> get taskDates {
    final dates = <DateTime>{};

    for (final task in _tasks) {
      final startDate = DateTime(
        task.scheduledAt.year,
        task.scheduledAt.month,
        task.scheduledAt.day,
      );

      switch (task.repeat) {
        case 'none':
          dates.add(startDate);
          break;

        case 'daily':
          for (int i = 0; i < 365; i++) {
            dates.add(
              startDate.add(
                Duration(days: i),
              ),
            );
          }
          break;

        case 'weekly':
          for (int i = 0; i < 365; i++) {
            final date = startDate.add(
              Duration(days: i),
            );

            if (date.weekday ==
                startDate.weekday) {
              dates.add(date);
            }
          }
          break;

        case 'custom':
          for (int i = 0; i < 365; i++) {
            final date = startDate.add(
              Duration(days: i),
            );

            if (task.repeatDays.contains(
              date.weekday,
            )) {
              dates.add(date);
            }
          }
          break;
      }
    }

    return dates;
  }
}