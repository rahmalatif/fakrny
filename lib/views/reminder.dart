import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled/l10n/app_localizations.dart';

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
  String selectedRepeat = 'none';
  List<int> selectedRepeatDays = [];
  final TextEditingController _titleController = TextEditingController();
  String selectedCategory = 'study';
  String selectedPriority = 'high';
  int reminderBefore = 30;
  bool isLoading = false;
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDark ? AppColor.darkBackground : AppColor.background;

  Color get surfaceColor =>
      isDark ? AppColor.darkSurface : AppColor.surface;

  Color get cardColor =>
      isDark ? AppColor.darkCard : AppColor.border;

  Color get primaryTextColor =>
      isDark ? AppColor.textWhite : AppColor.textPrimary;

  Color get secondaryTextColor =>
      isDark ? AppColor.textHint : AppColor.textSecondary;

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
      selectedRepeat = task.repeat;
      selectedRepeatDays = List<int>.from(task.repeatDays);
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

    if (selectedRepeat == 'custom' && selectedRepeatDays.isEmpty) {
      SnackBarHelper.show(
        context,
        message: 'Please choose repeat days',
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
          remindBefore: reminderBefore,
          repeat: selectedRepeat,
          repeatDays: List<int>.from(selectedRepeatDays),
        );

        final taskWithId = await taskProvider.addTask(task);

        if (taskWithId == null) {
          throw Exception(
            taskProvider.error ?? 'Failed to create task',
          );
        }

        await NotificationServices()
            .scheduleTaskNotification(taskWithId);
      } else {
        final notificationService = NotificationServices();

        await NotificationServices.cancelTaskNotification(widget.task!.id);

        final updatedTask = TaskModel(
          id: widget.task!.id,
          title: _titleController.text.trim(),
          description: widget.task!.description,
          scheduledAt: scheduledAt,
          category: selectedCategory,
          priority: selectedPriority,
          color: widget.task!.color,
          isCompleted: widget.task!.isCompleted,
          repeat: selectedRepeat,
          repeatDays: List<int>.from(selectedRepeatDays),
          remindBefore: reminderBefore,
          createdAt: widget.task!.createdAt,
          updatedAt: DateTime.now(),
        );

        final success =
        await taskProvider.updateTask(updatedTask);

        if (!success) {
          throw Exception(
            taskProvider.error ?? 'Failed to update task',
          );
        }

        if (!updatedTask.isCompleted) {
          await notificationService
              .scheduleTaskNotification(updatedTask);
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
    final l10n = AppLocalizations.of(context)!;

    if (selectedDate == null) {
      return l10n.chooseDate;
    }

    return '${selectedDate!.day}/'
        '${selectedDate!.month}/'
        '${selectedDate!.year}';
  }

  String get formattedTime {
    final l10n = AppLocalizations.of(context)!;

    if (selectedTime == null) {
      return l10n.chooseTime;
    }

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
    final l10n = AppLocalizations.of(context)!;

    switch (category) {
      case 'study':
        return l10n.study;
      case 'work':
        return l10n.work;
      case 'health':
        return l10n.health;
      default:
        return l10n.other;
    }
  }

  String priorityName(String priority) {
    final l10n = AppLocalizations.of(context)!;

    switch (priority) {
      case 'high':
        return l10n.high;
      case 'medium':
        return l10n.medium;
      default:
        return l10n.low;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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
                  _repeatSection(),
                  const SizedBox(height: 18),
                  _categorySection(),
                  const SizedBox(height: 20),
                  _reminderSection(),
                  const SizedBox(height: 20),
                  _prioritySection(),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 12,
              child: _saveButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final l10n = AppLocalizations.of(context)!;

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
          child: Icon(
            Icons.arrow_back,
            color: primaryTextColor,
            size: 28,
          ),
        ),
        const Spacer(),
        Column(
          children: [
            Text(
              widget.task == null
                  ? l10n.createReminder
                  : l10n.editReminder,
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.addReminderDetails,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 9,
              ),
            ),
          ],
        ),
        const Spacer(),
        const SizedBox(width: 28),
      ],
    );
  }

  Widget _titleSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.title,
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isDark
                  ? Colors.transparent
                  : AppColor.border,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 13),
              Icon(
                Icons.content_copy_outlined,
                color: secondaryTextColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 13,
                  ),
                  cursorColor: AppColor.primary,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: l10n.taskTitleHint,
                    hintStyle: TextStyle(
                      color: secondaryTextColor,
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
    final l10n = AppLocalizations.of(context)!;

    return _dateTimeCard(
      title: l10n.date,
      value: formattedDate,
      icon: Icons.calendar_month_outlined,
      onTap: selectDate,
    );
  }

  Widget _timeCard() {
    final l10n = AppLocalizations.of(context)!;

    return _dateTimeCard(
      title: l10n.time,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.transparent
                : AppColor.border,
          ),
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
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              color: secondaryTextColor,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  Widget _categorySection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.category,
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              l10n.chooseCategory,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 10,
              ),
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
                ? AppColor.primary.withValues(alpha: .08)
                : surfaceColor,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isSelected
                  ? AppColor.primary
                  : cardColor,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                categoryIcon(category),
                color: isSelected
                    ? AppColor.primary
                    : secondaryTextColor,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                categoryName(category),
                style: TextStyle(
                  color: isSelected
                      ? AppColor.primary
                      : secondaryTextColor,
                  fontSize: 9,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reminderSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.remindMe,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isDark
                  ? Colors.transparent
                  : AppColor.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: reminderBefore,
              isExpanded: true,
              dropdownColor: surfaceColor,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: secondaryTextColor,
                size: 21,
              ),
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 11,
              ),
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text(l10n.atTaskTime),
                ),
                DropdownMenuItem(
                  value: 5,
                  child: Text(l10n.minutesBefore(5)),
                ),
                DropdownMenuItem(
                  value: 10,
                  child: Text(l10n.minutesBefore(10)),
                ),
                DropdownMenuItem(
                  value: 15,
                  child: Text(l10n.minutesBefore(15)),
                ),
                DropdownMenuItem(
                  value: 30,
                  child: Text(l10n.minutesBefore(30)),
                ),
                DropdownMenuItem(
                  value: 60,
                  child: Text(l10n.oneHourBefore),
                ),
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.priority,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            _priorityButton(
              value: 'high',
              iconColor: AppColor.error,
            ),
            const SizedBox(width: 7),
            _priorityButton(
              value: 'medium',
              iconColor: Colors.amber,
            ),
            const SizedBox(width: 7),
            _priorityButton(
              value: 'low',
              iconColor: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _priorityButton({
    required String value,
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
                ? AppColor.error.withValues(alpha: .06)
                : surfaceColor,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isSelected
                  ? AppColor.error.withValues(alpha: .45)
                  : cardColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                priorityName(value),
                style: TextStyle(
                  color: isSelected
                      ? iconColor
                      : secondaryTextColor,
                  fontSize: 10,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.flag_outlined,
                color: iconColor,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _repeatSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.repeat,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isDark
                  ? Colors.transparent
                  : AppColor.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedRepeat,
              isExpanded: true,
              dropdownColor: surfaceColor,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: secondaryTextColor,
              ),
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 11,
              ),
              items: [
                DropdownMenuItem(
                  value: 'none',
                  child: Text(l10n.doesNotRepeat),
                ),
                DropdownMenuItem(
                  value: 'daily',
                  child: Text(l10n.everyDay),
                ),
                DropdownMenuItem(
                  value: 'weekly',
                  child: Text(l10n.everyWeek),
                ),
                DropdownMenuItem(
                  value: 'custom',
                  child: Text(l10n.customDays),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedRepeat = value;

                  if (value != 'custom') {
                    selectedRepeatDays = [];
                  }
                });
              },
            ),
          ),
        ),
        if (selectedRepeat == 'custom') ...[
          const SizedBox(height: 10),
          _repeatDaysSelector(),
        ],
      ],
    );
  }

  Widget _repeatDaysSelector() {
    final l10n = AppLocalizations.of(context)!;

    final days = [
      {'value': 1, 'label': l10n.mondayShort},
      {'value': 2, 'label': l10n.tuesdayShort},
      {'value': 3, 'label': l10n.wednesdayShort},
      {'value': 4, 'label': l10n.thursdayShort},
      {'value': 5, 'label': l10n.fridayShort},
      {'value': 6, 'label': l10n.saturdayShort},
      {'value': 7, 'label': l10n.sundayShort},
    ];

    return Row(
      children: days.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;

        final value = day['value'] as int;
        final label = day['label'] as String;

        final isSelected = selectedRepeatDays.contains(value);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == days.length - 1 ? 0 : 5,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedRepeatDays.remove(value);
                  } else {
                    selectedRepeatDays.add(value);
                  }

                  selectedRepeatDays.sort();
                });
              },
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.primary
                      : surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.primary
                        : cardColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColor.textWhite
                          : secondaryTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _saveButton() {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: isLoading ? null : saveReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          disabledBackgroundColor:
          AppColor.primary.withValues(alpha: .6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
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
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none,
              color: AppColor.textWhite,
              size: 16,
            ),
            const SizedBox(width: 7),
            Text(
              l10n.saveReminder,
              style: const TextStyle(
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