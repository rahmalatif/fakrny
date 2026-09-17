import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/design/widgets/snack_bar.dart';
import '../model/tasks.dart';
import '../provider/task_provider.dart';
import '../services/notification_services.dart';

class ReminderView extends StatefulWidget {
  final TaskModel? task;

  const ReminderView({super.key, this.task});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController _titleController = TextEditingController();

  String selectedCategory = 'study';
  String selectedPriority = 'high';

  int reminderBefore = 30;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      final task = widget.task!;

      _titleController.text = task.title;
      selectedDate = task.scheduledAt;
      selectedTime = TimeOfDay.fromDateTime(task.scheduledAt);

      selectedCategory = task.category;
      selectedPriority = task.priority;
      reminderBefore = task.remindBefore;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> saveReminder() async {

    if (selectedDate == null || selectedTime == null) {
      SnackBarHelper.show(
        context,
        message: 'Please fill all the details',
        type: SnackBarType.warning,
      );
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      SnackBarHelper.show(
        context,
        message: 'Please enter a task title',
        type: SnackBarType.warning,
      );
      return;
    }

    final scheduledAt = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    try {
      setState(() {
        isLoading = true;
      });

      final taskProvider = context.read<TaskProvider>();

      if (widget.task == null) {
        final task = TaskModel(
          id: '',
          title: _titleController.text.trim(),
          description: '',
          scheduledAt: scheduledAt,
          category: selectedCategory,
          priority: selectedPriority,
          color: 'primary',
          isCompleted: false,
          repeat: 'none',
          remindBefore: reminderBefore,
        );

        final taskWithId = await taskProvider.addTask(task);

        if (taskWithId == null) {
          throw Exception(taskProvider.error ?? 'Failed to create task');
        }

        await NotificationServices().scheduleTaskNotification(taskWithId);
      } else {
        await NotificationServices().cancelAllNotifications();

        final updatedTask = TaskModel(
          id: widget.task!.id,
          title: _titleController.text.trim(),
          description: widget.task!.description,
          scheduledAt: scheduledAt,
          category: selectedCategory,
          priority: selectedPriority,
          color: widget.task!.color,
          isCompleted: widget.task!.isCompleted,
          repeat: widget.task!.repeat,
          remindBefore: reminderBefore,
          createdAt: widget.task!.createdAt,
          updatedAt: DateTime.now(),
        );

        final success = await taskProvider.updateTask(updatedTask);

        if (!success) {
          throw Exception(taskProvider.error ?? 'Failed to update task');
        }

        await NotificationServices().cancelAllNotifications();

        await NotificationServices().scheduleTaskNotification(updatedTask);
      }

      if (!mounted) return;

      SnackBarHelper.show(
        context,
        message: widget.task == null
            ? 'Task added successfully'
            : 'Task updated successfully',
        type: SnackBarType.success,
      );

      _closeAfterSave();
    } catch (e) {
      if (!mounted) return;

      SnackBarHelper.show(
        context,
        message: 'Something went wrong: $e',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _closeAfterSave() {
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Reminder' : 'Edit Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter task title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate == null
                          ? 'Select date'
                          : '${selectedDate!.day}/'
                                '${selectedDate!.month}/'
                                '${selectedDate!.year}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: selectTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 12),
                    Text(
                      selectedTime == null
                          ? 'Select time'
                          : selectedTime!.format(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'study', child: Text('Study')),
                DropdownMenuItem(value: 'work', child: Text('Work')),
                DropdownMenuItem(value: 'personal', child: Text('Personal')),
                DropdownMenuItem(value: 'health', child: Text('Health')),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Priority',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedPriority,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedPriority = value;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Remind me before',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: reminderBefore,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('At time of task')),
                DropdownMenuItem(value: 5, child: Text('5 minutes before')),
                DropdownMenuItem(value: 10, child: Text('10 minutes before')),
                DropdownMenuItem(value: 15, child: Text('15 minutes before')),
                DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                DropdownMenuItem(value: 60, child: Text('1 hour before')),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  reminderBefore = value;
                });
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveReminder,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.task == null
                            ? 'Add Reminder'
                            : 'Update Reminder',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
