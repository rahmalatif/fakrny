import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/model/tasks.dart';

void main() {
  group('TaskModel', () {
    final scheduledAt = DateTime(2026, 9, 21, 18, 30);

    final task = TaskModel(
      id: 'task-1',
      title: 'Study Flutter',
      description: 'Complete testing',
      scheduledAt: scheduledAt,
      category: 'Study',
      priority: 'High',
      color: '#6C63FF',
      isCompleted: false,
      repeat: 'none',
      remindBefore: 15,
      createdAt: scheduledAt,
      updatedAt: scheduledAt, repeatDays: [],
    );

    test('toMap should convert TaskModel correctly', () {
      final map = task.toMap();

      expect(map['title'], 'Study Flutter');
      expect(map['description'], 'Complete testing');
      expect(
        (map['scheduledAt'] as Timestamp).toDate(),
        scheduledAt,
      );
      expect(map['category'], 'Study');
      expect(map['priority'], 'High');
      expect(map['color'], '#6C63FF');
      expect(map['isCompleted'], false);
      expect(map['repeat'], 'none');
      expect(map['remindBefore'], 15);
      expect(
        (map['createdAt'] as Timestamp).toDate(),
        scheduledAt,
      );
      expect(
        (map['updatedAt'] as Timestamp).toDate(),
        scheduledAt,
      );
    });

    test('fromMap should create TaskModel correctly', () {
      final map = {
        'title': 'Study Flutter',
        'description': 'Complete testing',
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'category': 'Study',
        'priority': 'High',
        'color': '#6C63FF',
        'isCompleted': false,
        'repeat': 'none',
        'remindBefore': 15,
        'createdAt': Timestamp.fromDate(scheduledAt),
        'updatedAt': Timestamp.fromDate(scheduledAt),
      };

      final result = TaskModel.fromMap('task-1', map);

      expect(result.id, 'task-1');
      expect(result.title, 'Study Flutter');
      expect(result.description, 'Complete testing');
      expect(result.scheduledAt, scheduledAt);
      expect(result.category, 'Study');
      expect(result.priority, 'High');
      expect(result.color, '#6C63FF');
      expect(result.isCompleted, false);
      expect(result.repeat, 'none');
      expect(result.remindBefore, 15);
      expect(result.createdAt, scheduledAt);
      expect(result.updatedAt, scheduledAt);
    });

    test('fromMap should use default values for optional fields', () {
      final map = {
        'title': 'Study Flutter',
        'scheduledAt': Timestamp.fromDate(scheduledAt),
      };

      final result = TaskModel.fromMap('task-1', map);

      expect(result.title, 'Study Flutter');
      expect(result.description, '');
      expect(result.category, '');
      expect(result.priority, '');
      expect(result.color, '');
      expect(result.isCompleted, false);
      expect(result.repeat, 'none');
      expect(result.remindBefore, 0);
      expect(result.createdAt, isNull);
      expect(result.updatedAt, isNull);
    });
  });
}