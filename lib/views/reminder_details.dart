import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/l10n/app_localizations.dart';
import 'package:untitled/model/tasks.dart';

import '../core/design/theme/app_color.dart';
import '../services/auth_services.dart';
import '../services/task_firestore_service.dart';

class ReminderDetailsView extends StatefulWidget {
  final TaskModel task;

  const ReminderDetailsView({super.key, required this.task});

  @override
  State<ReminderDetailsView> createState() => _ReminderDetailsViewState();
}

class _ReminderDetailsViewState extends State<ReminderDetailsView> {
  final TaskFirestoreService taskFirestoreService = TaskFirestoreService();

  final AuthServices authServices = AuthServices();
  late TaskModel task;
  late bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    task = widget.task;
    isCompleted = task.isCompleted;
  }

  bool isUpdating = false;

  Future<void> toggleCompleted() async {
    final currentUser = authServices.currentUser;

    if (currentUser == null) return;

    final newValue = !isCompleted;

    setState(() {
      isUpdating = true;
      isCompleted = newValue;

      task = TaskModel(
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
    });

    try {
      await taskFirestoreService.updateTask(
        uid: currentUser.uid,
        taskId: task.id,
        data: {'isCompleted': newValue},
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCompleted = !newValue;

        task = TaskModel(
          id: task.id,
          title: task.title,
          description: task.description,
          scheduledAt: task.scheduledAt,
          category: task.category,
          priority: task.priority,
          color: task.color,
          isCompleted: !newValue,
          repeat: task.repeat,
          remindBefore: task.remindBefore,
          createdAt: task.createdAt,
          updatedAt: task.updatedAt,
        );
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update task: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'م' : 'ص';

    return '$hour:$minute $period';
  }

  Future<void> _deleteReminder() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final currentUser = authServices.currentUser;

    if (currentUser == null) return;

    try {
      await taskFirestoreService.deleteTask(
        uid: currentUser.uid,
        taskId: task.id,
      );

      if (!mounted) return;

      context.pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete reminder')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _header(),

              const SizedBox(height: 18),

              _reminderHeader(),

              const SizedBox(height: 12),

              _infoSection(),

              const SizedBox(height: 15),

              _completeButton(),

              const SizedBox(height: 12),

              _actions(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? AppColor.darkSurface : AppColor.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppColor.darkCard
                  : AppColor.border.withOpacity(.1),
            ),
          ),
          child: IconButton(
            onPressed: () {
              context.pop(true);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: isDark ? AppColor.textWhite : AppColor.textPrimary,
            ),
          ),
        ),

        const Spacer(),

        Column(
          children: [
            Text(
              AppLocalizations.of(context)!.reminderDetails,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColor.textWhite : AppColor.textPrimary,
              ),
            ),

            Text(
              'Reminder Details',
              style: TextStyle(
                fontSize: 9,
                color: isDark ? AppColor.textHint : AppColor.textSecondary,
              ),
            ),
          ],
        ),

        const Spacer(),

        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? AppColor.darkSurface : AppColor.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppColor.darkCard
                  : AppColor.border.withOpacity(.1),
            ),
          ),
          child: IconButton(
            onPressed: () {
              _showMoreOptions();
            },
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: isDark ? AppColor.textWhite : AppColor.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reminderHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurface : AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .15 : .04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school_outlined, color: AppColor.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColor.textWhite : AppColor.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Text(
                      task.category,
                      style: const TextStyle(
                        color: AppColor.primary,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColor.textHint
                            : AppColor.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      task.priority,
                      style: TextStyle(
                        color: AppColor.error.withOpacity(.8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurface : AppColor.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.calendar_today_outlined,
            title: AppLocalizations.of(context)!.date,
            value:
                '${task.scheduledAt.day}/${task.scheduledAt.month}/${task.scheduledAt.year}',
          ),

          _divider(),

          _infoRow(
            icon: Icons.access_time,
            title: AppLocalizations.of(context)!.time,
            value: formatTime(task.scheduledAt),
          ),

          _divider(),

          _infoRow(
            icon: Icons.notifications_none,
            title: AppLocalizations.of(context)!.reminderBefore,
            value:
                '${task.remindBefore} ${AppLocalizations.of(context)!.minutes}',
          ),

          _divider(),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: isDark ? AppColor.textHint : AppColor.textSecondary,
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColor.textHint : AppColor.textSecondary,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color:
                  valueColor ??
                  (isDark ? AppColor.textWhite : AppColor.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Divider(
      height: 1,
      indent: 15,
      endIndent: 15,
      color: isDark ? AppColor.darkCard : AppColor.divider,
    );
  }

  Widget _completeButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isUpdating ? null : toggleCompleted,

        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? AppColor.success : AppColor.primary,

          foregroundColor: AppColor.textWhite,

          elevation: 2,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),

        child: isUpdating
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
                  Icon(
                    isCompleted ? Icons.check_circle_outline : Icons.check,
                    size: 19,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    isCompleted
                        ? AppLocalizations.of(context)!.completed
                        : AppLocalizations.of(context)!.markCompleted,

                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _actions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _editReminder();
            },
            icon: Icon(Icons.edit_outlined, size: 18, color: AppColor.primary),
            label: Text(AppLocalizations.of(context)!.edit),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.primary,
              backgroundColor: isDark ? AppColor.darkSurface : AppColor.surface,
              side: BorderSide(color: AppColor.primary.withOpacity(.15)),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _deleteReminder();
            },
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppColor.error,
            ),
            label: Text(AppLocalizations.of(context)!.delete),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.error,
              backgroundColor: isDark ? AppColor.darkSurface : AppColor.surface,
              side: BorderSide(color: AppColor.error.withOpacity(.15)),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editReminder() async {
    final result = await context.push('/Reminder', extra: task);

    if (result == true && mounted) {
      final currentUser = authServices.currentUser;

      if (currentUser == null) return;

      final updatedTask = await taskFirestoreService.getTask(
        uid: currentUser.uid,
        taskId: task.id,
      );

      if (updatedTask == null || !mounted) return;

      setState(() {
        task = updatedTask;
        isCompleted = updatedTask.isCompleted;
      });
    }
  }

  void _showMoreOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColor.darkSurface : AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.edit_outlined,
                  color: isDark ? AppColor.textWhite : AppColor.textPrimary,
                ),
                title: Text(
                  AppLocalizations.of(context)!.edit,
                  style: TextStyle(
                    color: isDark ? AppColor.textWhite : AppColor.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editReminder();
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColor.error,
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: AppColor.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteReminder();
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
