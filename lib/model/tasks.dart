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
  final List<int> repeatDays;
  final int remindBefore;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> completedDates;
  final DateTime? repeatEndDate; // تاريخ انتهاء التكرار

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
    required this.repeatDays,
    required this.remindBefore,
    this.createdAt,
    this.updatedAt,
    this.completedDates = const [],
    this.repeatEndDate,
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
      'repeatDays': repeatDays,
      'remindBefore': remindBefore,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedDates': completedDates,
      'repeatEndDate': repeatEndDate != null
          ? Timestamp.fromDate(repeatEndDate!)
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
      repeatDays: (map['repeatDays'] as List<dynamic>?)
          ?.map((e) => int.tryParse(e.toString()) ?? 0)
          .toList() ??
          [],
      remindBefore: map['remindBefore'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      completedDates: List<String>.from(
        map['completedDates'] ?? [],
      ),
      repeatEndDate: map['repeatEndDate'] is Timestamp
          ? (map['repeatEndDate'] as Timestamp).toDate()
          : null,
    );
  }
}