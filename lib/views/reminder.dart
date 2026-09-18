import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/design/theme/app_color.dart';
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
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
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
    if (_titleController.text.trim().isEmpty) {
      SnackBarHelper.show(
        context,
        message: 'Please enter a task title',
        type: SnackBarType.warning,
      );
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      SnackBarHelper.show(
        context,
        message: 'Please choose date and time',
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

    final reminderTime = scheduledAt.subtract(
      Duration(minutes: reminderBefore),
    );

    if (reminderTime.isBefore(DateTime.now())) {
      SnackBarHelper.show(
        context,
        message: 'Please choose a future time for the reminder',
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
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
        await NotificationServices().cancelTaskNotification(widget.task!.id);

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

        if (!updatedTask.isCompleted) {
          await NotificationServices().scheduleTaskNotification(updatedTask);
        }
      }

      if (!mounted) return;

      SnackBarHelper.show(
        context,
        message: widget.task == null
            ? 'Task added successfully'
            : 'Task updated successfully',
        type: SnackBarType.success,
      );

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
        message: e.toString().replaceFirst('Exception: ', ''),
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
    if (context.canPop()) {
      context.pop(true);
    } else {
      context.go('/Home');
    }
  }

  String get formattedDate {
    if (selectedDate == null) return 'Choose Date';

    return '${selectedDate!.day}/'
        '${selectedDate!.month}/'
        '${selectedDate!.year}';
  }

  String get formattedTime {
    if (selectedTime == null) return 'Choose Time';

    return selectedTime!.format(context);
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'study':
        return Icons.school_outlined;
      case 'work':
        return Icons.work_outline;
      case 'health':
        return Icons.favorite_border;
      default:
        return Icons.more_horiz;
    }
  }

  String categoryName(String category) {
    switch (category) {
      case 'study':
        return 'Study';
      case 'work':
        return 'Work';
      case 'health':
        return 'Health';
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),

                  const SizedBox(height: 26),

                  _titleSection(),

                  const SizedBox(height: 18),

                  _dateCard(),

                  const SizedBox(height: 10),

                  _timeCard(),

                  const SizedBox(height: 18),

                  _categorySection(),

                  const SizedBox(height: 20),

                  _reminderSection(),

                  const SizedBox(height: 20),

                  _prioritySection(),
                ],
              ),
            ),

            Positioned(left: 24, right: 24, bottom: 12, child: _saveButton()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/Home');
            }
          },
          child: const Icon(
            Icons.arrow_back,
            color: AppColor.textWhite,
            size: 28,
          ),
        ),

        const Spacer(),

        Column(
          children: [
            Text(
              widget.task == null ? 'Create Reminder' : 'Edit Reminder',
              style: const TextStyle(
                color: AppColor.textWhite,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Add your reminder details',
              style: TextStyle(color: AppColor.textHint, fontSize: 9),
            ),
          ],
        ),

        const Spacer(),

        const SizedBox(width: 28),
      ],
    );
  }

  Widget _titleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(color: AppColor.textSecondary, fontSize: 10),
        ),

        const SizedBox(height: 6),

        Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              const SizedBox(width: 13),

              const Icon(
                Icons.content_copy_outlined,
                color: AppColor.textSecondary,
                size: 20,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 13,
                  ),
                  cursorColor: AppColor.primary,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'example:study Biology',
                    hintStyle: TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateCard() {
    return _dateTimeCard(
      title: 'Date',
      value: formattedDate,
      icon: Icons.calendar_month_outlined,
      onTap: selectDate,
    );
  }

  Widget _timeCard() {
    return _dateTimeCard(
      title: 'Time',
      value: formattedTime,
      icon: Icons.access_time_outlined,
      onTap: selectTime,
    );
  }

  Widget _dateTimeCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColor.darkSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColor.textWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Icon(icon, color: AppColor.textSecondary, size: 19),
          ],
        ),
      ),
    );
  }

  Widget _categorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Category',
              style: TextStyle(
                color: AppColor.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            const Text(
              'Choose Category',
              style: TextStyle(color: AppColor.textSecondary, fontSize: 10),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            _categoryButton('study'),
            const SizedBox(width: 7),
            _categoryButton('work'),
            const SizedBox(width: 7),
            _categoryButton('health'),
            const SizedBox(width: 7),
            _categoryButton('other'),
          ],
        ),
      ],
    );
  }

  Widget _categoryButton(String category) {
    final isSelected = selectedCategory == category;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
        },
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primary.withOpacity(.08)
                : AppColor.darkSurface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isSelected ? AppColor.primary : AppColor.darkCard,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                categoryIcon(category),
                color: isSelected ? AppColor.primary : AppColor.textSecondary,
                size: 20,
              ),

              const SizedBox(height: 4),

              Text(
                categoryName(category),
                style: TextStyle(
                  color: isSelected ? AppColor.primary : AppColor.textSecondary,
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Remind me',
          style: TextStyle(
            color: AppColor.textWhite,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 9),

        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: AppColor.darkSurface,
            borderRadius: BorderRadius.circular(11),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: reminderBefore,
              isExpanded: true,
              dropdownColor: AppColor.darkSurface,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColor.textSecondary,
                size: 21,
              ),
              style: const TextStyle(color: AppColor.textWhite, fontSize: 11),
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
          ),
        ),
      ],
    );
  }

  Widget _prioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            color: AppColor.textWhite,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 9),

        Row(
          children: [
            _priorityButton(
              value: 'high',
              title: 'High',
              iconColor: AppColor.error,
            ),

            const SizedBox(width: 7),

            _priorityButton(
              value: 'medium',
              title: 'Medium',
              iconColor: Colors.amber,
            ),

            const SizedBox(width: 7),

            _priorityButton(
              value: 'low',
              title: 'Low',
              iconColor: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _priorityButton({
    required String value,
    required String title,
    required Color iconColor,
  }) {
    final isSelected = selectedPriority == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPriority = value;
          });
        },
        child: Container(
          height: 47,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.error.withOpacity(.06)
                : AppColor.darkSurface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isSelected
                  ? AppColor.error.withOpacity(.45)
                  : AppColor.darkCard,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? iconColor : AppColor.textSecondary,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),

              const SizedBox(width: 5),

              Icon(Icons.flag_outlined, color: iconColor, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: isLoading ? null : saveReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          disabledBackgroundColor: AppColor.primary.withOpacity(.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.textWhite,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    color: AppColor.textWhite,
                    size: 16,
                  ),

                  SizedBox(width: 7),

                  Text(
                    'Save Reminder',
                    style: TextStyle(
                      color: AppColor.textWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
