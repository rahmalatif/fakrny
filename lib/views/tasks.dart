import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/design/theme/app_color.dart';
import '../core/design/widgets/empty_states.dart';
import '../core/design/widgets/nav_bar.dart';
import '../l10n/app_localizations.dart';
import '../model/tasks.dart';
import '../provider/task_provider.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = context.watch<TaskProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const CustomNavBar(currentIndex: 1),
      );
    }

    if (taskProvider.error != null && taskProvider.tasks.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              taskProvider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColor.textWhite : AppColor.textPrimary,
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CustomNavBar(currentIndex: 1),
      );
    }

    final allTasks = List<TaskModel>.from(taskProvider.tasks);

    final completedTasksList = allTasks
        .where((task) => task.isCompleted)
        .toList();

    final pendingTasksList = allTasks
        .where((task) => !task.isCompleted)
        .toList();

    final completedTasks = completedTasksList.length;
    final pendingTasks = pendingTasksList.length;

    final displayedTasks = selectedTab == 0
        ? List<TaskModel>.from(allTasks)
        : List<TaskModel>.from(completedTasksList);

    displayedTasks.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return Scaffold(
      backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Text(
                  l10n.tasks,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColor.textWhite : AppColor.textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: isDark ? AppColor.darkSurface : AppColor.secondary,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              selectedTab = 0;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedTab == 0
                                  ? AppColor.grad1
                                  : AppColor.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.all,
                              style: TextStyle(
                                color: selectedTab == 0
                                    ? AppColor.textWhite
                                    : isDark
                                    ? AppColor.textHint
                                    : AppColor.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              selectedTab = 1;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedTab == 1
                                  ? AppColor.grad1
                                  : AppColor.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.done,
                              style: TextStyle(
                                color: selectedTab == 1
                                    ? AppColor.textWhite
                                    : isDark
                                    ? AppColor.textHint
                                    : AppColor.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    _container(
                      context: context,
                      value: l10n.totalTasks,
                      title: allTasks.length.toString(),
                    ),
                    _container(
                      context: context,
                      value: l10n.completedTasks,
                      title: completedTasks.toString(),
                    ),
                    _container(
                      context: context,
                      value: l10n.pendingTasks,
                      title: pendingTasks.toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              if (displayedTasks.isNotEmpty)
                ...displayedTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 10,
                    ),
                    child: _taskCard(task),
                  ),
                ),
              if (displayedTasks.isEmpty)
                EmptyState(
                  icon: selectedTab == 1
                      ? Icons.check_circle_outline
                      : Icons.task_alt,
                  title: selectedTab == 1
                      ? l10n.noCompletedTasks
                      : l10n.noTasksYet,
                  message: selectedTab == 1
                      ? l10n.noCompletedTasksMessage
                      : l10n.noTasksYetMessage,
                  buttonText: selectedTab == 0 ? l10n.createTask : null,
                  onPressed: selectedTab == 0
                      ? () async {
                          final taskProvider = context.read<TaskProvider>();

                          final result = await context.push('/Reminder');

                          if (!mounted) return;

                          if (result == true) {
                            await taskProvider.loadTasks();
                          }
                        }
                      : null,
                ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }

  Future<void> _toggleTask(TaskModel task) async {
    final taskProvider = context.read<TaskProvider>();
    final l10n = AppLocalizations.of(context)!;

    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      scheduledAt: task.scheduledAt,
      category: task.category,
      priority: task.priority,
      color: task.color,
      isCompleted: !task.isCompleted,
      repeat: task.repeat,
      repeatDays: task.repeatDays,
      remindBefore: task.remindBefore,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(),
    );

    final success = await taskProvider.updateTask(
      updatedTask,
      languageCode: Localizations.localeOf(context).languageCode,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(taskProvider.error ?? l10n.errorUpdatingTask)),
      );
    }
  }

  Widget _taskCard(TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final time =
        '${task.scheduledAt.hour.toString().padLeft(2, '0')}:'
        '${task.scheduledAt.minute.toString().padLeft(2, '0')}';

    final date =
        '${task.scheduledAt.day.toString().padLeft(2, '0')}/'
        '${task.scheduledAt.month.toString().padLeft(2, '0')}/'
        '${task.scheduledAt.year}';

    final textColor = isDark ? AppColor.textWhite : AppColor.textPrimary;

    final secondaryColor = isDark ? AppColor.textHint : AppColor.textSecondary;

    final categoryColor = _getCategoryColor(task.category);

    return GestureDetector(
      onTap: () => _toggleTask(task),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColor.darkSurface : AppColor.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: task.isCompleted
                ? AppColor.success.withValues(alpha: 0.35)
                : isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColor.border.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completion Checkbox
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggleTask(task),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 23,
                height: 23,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? AppColor.success
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColor.success
                        : isDark
                        ? AppColor.disabled
                        : AppColor.border,
                    width: 1.5,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColor.textWhite,
                        size: 15,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // Task Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Details Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: task.isCompleted
                                ? secondaryColor
                                : textColor,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: secondaryColor,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Details Button
                      InkWell(
                        onTap: () {
                          context.go('/ReminderDetails', extra: task);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColor.darkCard
                                : AppColor.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Date, Time and Category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _taskInfoItem(
                              icon: Icons.calendar_today_rounded,
                              value: date,
                              color: secondaryColor,
                            ),
                            _taskInfoItem(
                              icon: Icons.access_time_rounded,
                              value: time,
                              color: secondaryColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: categoryColor.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Text(
                              task.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Completion Status
                  if (task.isCompleted) ...[
                    const SizedBox(height: 12),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColor.success,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          AppLocalizations.of(context)!.completed,
                          style: const TextStyle(
                            color: AppColor.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskInfoItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'دراسة':
      case 'study':
        return AppColor.primary;

      case 'عمل':
      case 'work':
        return AppColor.info;

      case 'شخصي':
      case 'personal':
        return AppColor.error;

      default:
        return AppColor.primary;
    }
  }

  static Widget _container({
    required BuildContext context,
    required String value,
    required String title,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isDark ? AppColor.darkCard : AppColor.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColor.textHint : AppColor.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: isDark ? AppColor.textWhite : AppColor.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
