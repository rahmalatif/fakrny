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
          child: Text(
            taskProvider.error!,
            style: TextStyle(
              color: isDark ? AppColor.textWhite : AppColor.textPrimary,
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
                padding: const EdgeInsets.all(18),
                child: Text(
                  l10n.tasks,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColor.textWhite : AppColor.textPrimary,
                  ),
                ),
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isDark ? AppColor.darkSurface : AppColor.secondary,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
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
                            borderRadius: BorderRadius.circular(20),
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
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
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
                            borderRadius: BorderRadius.circular(20),
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
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

    final success = await taskProvider.updateTask(updatedTask);

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

    return GestureDetector(
      onTap: () => _toggleTask(task),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColor.darkSurface : AppColor.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .20 : .04),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleTask(task),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted
                      ? AppColor.success
                      : isDark
                      ? AppColor.darkCard
                      : AppColor.surface,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColor.success
                        : isDark
                        ? AppColor.disabled
                        : AppColor.border,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(
                        Icons.check,
                        color: AppColor.textWhite,
                        size: 14,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: task.isCompleted
                                ? isDark
                                      ? AppColor.textHint
                                      : AppColor.textSecondary
                                : isDark
                                ? AppColor.textWhite
                                : AppColor.textPrimary,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColor.textHint
                              : AppColor.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        task.category,
                      ).withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      task.category,
                      style: TextStyle(
                        color: _getCategoryColor(task.category),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

    return Container(
      height: 80,
      width: 100,
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkCard : AppColor.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
            blurRadius: 8,
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
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColor.textHint : AppColor.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: isDark ? AppColor.textWhite : AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
