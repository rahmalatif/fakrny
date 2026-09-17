import 'package:flutter/foundation.dart';

import '../model/tasks.dart';
import '../services/task_firestore_service.dart';
import '../services/auth_services.dart';

class TaskProvider extends ChangeNotifier {
  final TaskFirestoreService taskFirestoreService;
  final AuthServices authServices;

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

      final userTasks = await taskFirestoreService.getTasks(currentUser.uid);

      _tasks = userTasks;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }
  Future<TaskModel?> addTask(TaskModel task) async {
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
        remindBefore: task.remindBefore,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );

      _tasks.add(newTask);

      _tasks.sort(
            (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
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


  Future<void> toggleTask(TaskModel task) async {
    final currentUser = authServices.currentUser;

    if (currentUser == null) return;

    final newValue = !task.isCompleted;

    final index = _tasks.indexWhere((element) => element.id == task.id);

    if (index == -1) return;

    _tasks[index] = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      scheduledAt: task.scheduledAt,
      category: task.category,
      priority: task.priority,
      color: task.color,
      isCompleted: newValue,
      repeat: task.repeat,
      remindBefore: task.remindBefore,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );

    notifyListeners();

    await taskFirestoreService.updateTask(
      uid: currentUser.uid,
      taskId: task.id,
      data: {'isCompleted': newValue},
    );
  }
  List<TaskModel> get todayTasks {
    final now = DateTime.now();

    return tasks.where((task) {
      return task.scheduledAt.year == now.year &&
          task.scheduledAt.month == now.month &&
          task.scheduledAt.day == now.day;
    }).toList();
  }
  Future<bool> updateTask(TaskModel task) async {
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
          'remindBefore': task.remindBefore,
        },
      );

      final index = _tasks.indexWhere(
            (element) => element.id == task.id,
      );

      if (index != -1) {
        _tasks[index] = task;

        _tasks.sort(
              (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
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

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
