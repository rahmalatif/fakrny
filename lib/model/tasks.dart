import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final String category;
  final String priority;
  final String color;
  final bool isCompleted;
  final String repeat;
  final int remindBefore;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.category,
    required this.priority,
    required this.color,
    required this.isCompleted,
    required this.repeat,
    required this.remindBefore,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'category': category,
      'priority': priority,
      'color': color,
      'isCompleted': isCompleted,
      'repeat': repeat,
      'remindBefore': remindBefore,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : null,
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : null,
    };
  }

  factory TaskModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',

      scheduledAt: (map['scheduledAt'] as Timestamp).toDate(),

      category: map['category'] ?? '',
      priority: map['priority'] ?? '',
      color: map['color'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      repeat: map['repeat'] ?? 'none',
      remindBefore: map['remindBefore'] ?? 0,

      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,

      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}