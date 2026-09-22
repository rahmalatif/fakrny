import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:untitled/model/tasks.dart';
import 'package:untitled/provider/task_provider.dart';
import 'package:untitled/services/auth_services.dart';
import 'package:untitled/services/task_firestore_service.dart';
import 'package:untitled/services/user_firestore_service.dart';


class MockAuthServices extends Mock implements AuthServices {}

class MockTaskFirestoreService extends Mock
    implements TaskFirestoreService {}

class MockUserFirestoreService extends Mock
    implements UserFirestoreService {}

class FakeTaskModel extends Fake implements TaskModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTaskModel());
  });

  late MockAuthServices authServices;
  late MockTaskFirestoreService taskFirestoreService;
  late MockUserFirestoreService userFirestoreService;
  late TaskProvider provider;

  setUp(() {
    authServices = MockAuthServices();
    taskFirestoreService = MockTaskFirestoreService();
    userFirestoreService = MockUserFirestoreService();

    provider = TaskProvider(
      taskFirestoreService: taskFirestoreService,
      authServices: authServices,
      userFirestoreService: userFirestoreService,
    );
  });

  TaskModel createTask({
    required String id,
    required DateTime scheduledAt,
    bool isCompleted = false,
  }) {
    return TaskModel(
      id: id,
      title: 'Test Task',
      description: 'Test Description',
      scheduledAt: scheduledAt,
      category: 'Study',
      priority: 'High',
      color: '#6C63FF',
      isCompleted: isCompleted,
      repeat: 'none',
      remindBefore: 15,
      createdAt: scheduledAt,
      updatedAt: scheduledAt,
      repeatDays: [],
    );
  }

  group('TaskProvider - todayTasks', () {
    test('should return only tasks scheduled for today', () {
      final now = DateTime.now();

      final todayTask = createTask(
        id: 'today',
        scheduledAt: DateTime(
          now.year,
          now.month,
          now.day,
          10,
        ),
      );

      final tomorrowTask = createTask(
        id: 'tomorrow',
        scheduledAt: DateTime(
          now.year,
          now.month,
          now.day + 1,
          10,
        ),
      );

      final yesterdayTask = createTask(
        id: 'yesterday',
        scheduledAt: DateTime(
          now.year,
          now.month,
          now.day - 1,
          10,
        ),
      );

      provider.tasks.addAll([
        todayTask,
        tomorrowTask,
        yesterdayTask,
      ]);

      final result = provider.todayTasks;

      expect(result.length, 1);
      expect(result.first.id, 'today');
    });

    test('should return empty list when there are no tasks today', () {
      final now = DateTime.now();

      provider.tasks.add(
        createTask(
          id: 'tomorrow',
          scheduledAt: DateTime(
            now.year,
            now.month,
            now.day + 1,
          ),
        ),
      );

      expect(provider.todayTasks, isEmpty);
    });
  });

  group('TaskProvider - tasksForDate', () {
    test('should return tasks for selected date', () {
      final selectedDate = DateTime(2026, 9, 21);

      provider.tasks.addAll([
        createTask(
          id: 'task-1',
          scheduledAt: DateTime(2026, 9, 21, 10),
        ),
        createTask(
          id: 'task-2',
          scheduledAt: DateTime(2026, 9, 21, 18),
        ),
        createTask(
          id: 'task-3',
          scheduledAt: DateTime(2026, 9, 22, 10),
        ),
      ]);

      final result = provider.tasksForDate(selectedDate);

      expect(result.length, 2);
      expect(
        result.map((task) => task.id),
        containsAll(['task-1', 'task-2']),
      );
    });

    test('should return empty list when date has no tasks', () {
      provider.tasks.add(
        createTask(
          id: 'task-1',
          scheduledAt: DateTime(2026, 9, 21),
        ),
      );

      final result = provider.tasksForDate(
        DateTime(2026, 9, 25),
      );

      expect(result, isEmpty);
    });
  });

  group('TaskProvider - taskDates', () {
    test('should return unique dates containing tasks', () {
      provider.tasks.addAll([
        createTask(
          id: 'task-1',
          scheduledAt: DateTime(2026, 9, 21, 10),
        ),
        createTask(
          id: 'task-2',
          scheduledAt: DateTime(2026, 9, 21, 18),
        ),
        createTask(
          id: 'task-3',
          scheduledAt: DateTime(2026, 9, 22, 10),
        ),
      ]);

      final result = provider.taskDates;

      expect(result.length, 2);

      expect(
        result,
        contains(DateTime(2026, 9, 21)),
      );

      expect(
        result,
        contains(DateTime(2026, 9, 22)),
      );
    });

    test('should return empty set when there are no tasks', () {
      expect(provider.taskDates, isEmpty);
    });
  });

  group('TaskProvider - addTask', () {
    test('should return null when user is not logged in', () async {
      when(
            () => authServices.currentUser,
      ).thenReturn(null);

      final task = createTask(
        id: 'task-1',
        scheduledAt: DateTime(2026, 9, 21),
      );

      final result = await provider.addTask(task);

      expect(result, isNull);
      expect(provider.tasks, isEmpty);
      expect(provider.error, 'User is not logged in');

      verifyNever(
            () => taskFirestoreService.addTask(
          uid: any(named: 'uid'),
          task: any(named: 'task'),
        ),
      );
    });
  });

  group('TaskProvider - updateTask', () {
    test('should return false when user is not logged in', () async {
      when(
            () => authServices.currentUser,
      ).thenReturn(null);

      final task = createTask(
        id: 'task-1',
        scheduledAt: DateTime(2026, 9, 21),
      );

      final result = await provider.updateTask(task);

      expect(result, false);
      expect(provider.error, 'User is not logged in');
    });
  });

  group('TaskProvider - deleteTask', () {
    test('should return false when user is not logged in', () async {
      when(
            () => authServices.currentUser,
      ).thenReturn(null);

      final result = await provider.deleteTask('task-1');

      expect(result, false);
      expect(provider.error, 'User is not logged in');
    });
  });
}