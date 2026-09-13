import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/l10n/app_localizations.dart';
import 'package:untitled/services/task_firestore_service.dart';

import '../core/design/theme/app_color.dart';
import '../core/design/widgets/form.dart';
import '../core/design/widgets/snack_bar.dart';
import '../model/tasks.dart';

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
  final TaskFirestoreService taskFirestoreService = TaskFirestoreService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    if (task != null) {
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

  Future<void> saveReminder() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      SnackBarHelper.show(
        context,
        message: 'Please Login first',
        type: SnackBarType.error,
      );
      return;
    }
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

    if (selectedDate == null || selectedTime == null) {
      SnackBarHelper.show(
        context,
        message: 'Please enter a Date and Time',
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

        await taskFirestoreService.addTask(uid: user.uid, task: task);
      } else {
        await taskFirestoreService.updateTask(
          uid: user.uid,
          taskId: widget.task!.id,
          data: {
            'title': _titleController.text.trim(),
            'scheduledAt': scheduledAt,
            'category': selectedCategory,
            'priority': selectedPriority,
            'remindBefore': reminderBefore,
          },
        );
      }
      SnackBarHelper.show(
        context,
        message: widget.task == null
            ? 'Reminder created successfully'
            : 'Reminder updated successfully',
        type: SnackBarType.success,
      );

      _closeAfterSave();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save reminder: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _closeAfterSave() {
    if (!mounted) return;

    if (context.canPop()) {
      context.pop(true);
    } else {
      context.go('/Home');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
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

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  String _getDateText() {
    if (selectedDate == null) {
      return AppLocalizations.of(context)!.chooseDate;
    }

    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  String _getTimeText() {
    if (selectedTime == null) {
      return AppLocalizations.of(context)!.chooseTime;
    }

    return selectedTime!.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,

      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (widget.task == null) {
                            context.go('/Home');
                          } else {
                            context.pop();
                          }
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDark
                              ? AppColor.textWhite
                              : AppColor.textPrimary,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        AppLocalizations.of(context)!.createReminder,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isDark
                              ? AppColor.textWhite
                              : AppColor.textPrimary,
                        ),
                      ),

                      const Spacer(),

                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Text(
                  AppLocalizations.of(context)!.createReminderSub,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: isDark ? AppColor.textHint : AppColor.textSecondary,
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: MediaQuery.of(context).size.width * .9,
                  child: AppTextField(
                    hintText: AppLocalizations.of(context)!.titleHint,
                    keyboardType: TextInputType.text,
                    prefixIcon: Icon(
                      Icons.file_copy_outlined,
                      color: isDark
                          ? AppColor.textHint
                          : AppColor.textSecondary,
                    ),
                    title: AppLocalizations.of(context)!.title,
                    controller: _titleController,
                  ),
                ),

                const SizedBox(height: 15),

                _container(
                  value: _getDateText(),
                  title: AppLocalizations.of(context)!.date,
                  icon: Icon(
                    Icons.date_range,
                    color: isDark ? AppColor.textHint : AppColor.textSecondary,
                  ),
                  onTap: _selectDate,
                  height: 50,
                ),

                const SizedBox(height: 20),

                _container(
                  value: _getTimeText(),
                  title: AppLocalizations.of(context)!.time,
                  icon: Icon(
                    Icons.access_time,
                    color: isDark ? AppColor.textHint : AppColor.textSecondary,
                  ),
                  onTap: _selectTime,
                  height: 50,
                ),

                const SizedBox(height: 10),

                _categorycontainer(),

                const SizedBox(height: 10),

                _prioritySection(),

                SizedBox(height: 120),

                SizedBox(
                  width: MediaQuery.of(context).size.width * .9,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.textWhite,
                      elevation: 3,
                      shadowColor: AppColor.primary.withOpacity(.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.textWhite,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.notifications_none, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.saveReminder,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _container({
    required String value,
    required String title,
    required Icon icon,
    required VoidCallback onTap,
    required double height,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: MediaQuery.of(context).size.width * .9,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: isDark ? AppColor.darkSurface : AppColor.surface,

          borderRadius: BorderRadius.circular(10),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.20 : 0.05),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppColor.textHint : AppColor.textSecondary,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? AppColor.textWhite : AppColor.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            const Spacer(),

            IconButton(onPressed: onTap, icon: icon),
          ],
        ),
      ),
    );
  }

  Widget _categorycontainer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? AppColor.textWhite : AppColor.textPrimary,
                ),
              ),

              const Spacer(),

              Text(
                AppLocalizations.of(context)!.chooseCategory,
                style: TextStyle(
                  color: isDark ? AppColor.textHint : AppColor.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _categoryItem(
              value: 'study',
              title: AppLocalizations.of(context)!.study,
              icon: Icons.school_outlined,
            ),

            const SizedBox(width: 8),

            _categoryItem(
              value: 'work',
              title: AppLocalizations.of(context)!.work,
              icon: Icons.work_outline,
            ),

            const SizedBox(width: 8),

            _categoryItem(
              value: 'health',
              title: AppLocalizations.of(context)!.health,
              icon: Icons.favorite_border,
            ),

            const SizedBox(width: 8),

            _categoryItem(
              value: 'other',
              title: AppLocalizations.of(context)!.other,
              icon: Icons.more_horiz,
            ),
          ],
        ),
      ],
    );
  }

  Widget _categoryItem({
    required String value,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = selectedCategory == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = value;
        });
      },
      child: Container(
        width: 68,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primary.withOpacity(.08)
              : isDark
              ? AppColor.darkSurface
              : AppColor.surface,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: isSelected
                ? AppColor.primary.withOpacity(.3)
                : isDark
                ? AppColor.darkCard.withOpacity(.4)
                : AppColor.border.withOpacity(.5),
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColor.primary
                  : isDark
                  ? AppColor.textHint
                  : AppColor.textSecondary,
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColor.primary
                    : isDark
                    ? AppColor.textHint
                    : AppColor.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prioritySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            AppLocalizations.of(context)!.priority,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? AppColor.textWhite : AppColor.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _priorityItem(
              value: 'high',
              title: AppLocalizations.of(context)!.high,
              iconColor: AppColor.error,
            ),

            const SizedBox(width: 8),

            _priorityItem(
              value: 'medium',
              title: AppLocalizations.of(context)!.medium,
              iconColor: AppColor.warning,
            ),

            const SizedBox(width: 8),

            _priorityItem(
              value: 'low',
              title: AppLocalizations.of(context)!.low,
              iconColor: AppColor.success,
            ),
          ],
        ),
      ],
    );
  }

  Widget _priorityItem({
    required String value,
    required String title,
    required Color iconColor,
  }) {
    final bool isSelected = selectedPriority == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPriority = value;
        });
      },
      child: Container(
        width: 92,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected
              ? iconColor.withOpacity(.06)
              : isDark
              ? AppColor.darkSurface
              : AppColor.surface,

          borderRadius: BorderRadius.circular(10),

          border: Border.all(
            color: isSelected
                ? iconColor.withOpacity(.25)
                : isDark
                ? AppColor.darkCard.withOpacity(.4)
                : AppColor.border.withOpacity(.5),
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? iconColor
                    : isDark
                    ? AppColor.textHint
                    : AppColor.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),

            const SizedBox(width: 8),

            Icon(Icons.flag_outlined, size: 16, color: iconColor),
          ],
        ),
      ),
    );
  }
}
