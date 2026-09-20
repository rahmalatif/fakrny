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
        body: Center(child: Text('Error: ${taskProvider.error}')),
        bottomNavigationBar: const CustomNavBar(currentIndex: 1),
      );
    }

    final allTasks = taskProvider.tasks;

    final completedTaskList = allTasks
        .where((task) => task.isCompleted == true)
        .toList();

    final tasks = selectedTab == 0 ? allTasks : completedTaskList;

    final now = DateTime.now();

    final todayTasks = tasks.where((task) {
      return task.scheduledAt.year == now.year &&
          task.scheduledAt.month == now.month &&
          task.scheduledAt.day == now.day;
    }).toList();

    final tomorrow = now.add(const Duration(days: 1));

    final tomorrowTasks = tasks.where((task) {
      return task.scheduledAt.year == tomorrow.year &&
          task.scheduledAt.month == tomorrow.month &&
          task.scheduledAt.day == tomorrow.day;
    }).toList();

    final laterTasks = tasks.where((task) {
      return task.scheduledAt.isAfter(
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59),
      );
    }).toList();

    final completedTasks = completedTaskList.length;

    final pendingTasks = allTasks.length - completedTasks;

    return Scaffold(
      backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.tasks,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColor.textWhite
                                : AppColor.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.1,
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
                                ? AppColor.Grad1
                                : AppColor.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)!.all,
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
                                ? AppColor.Grad1
                                : AppColor.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)!.done,
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
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _container(
                      context: context,
                      value: AppLocalizations.of(context)!.totalTasks,
                      title: allTasks.length.toString(),
                    ),
                    _container(
                      context: context,
                      value: AppLocalizations.of(context)!.completedTasks,
                      title: completedTasks.toString(),
                    ),
                    _container(
                      context: context,
                      value: AppLocalizations.of(context)!.pendingTasks,
                      title: pendingTasks.toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              if (selectedTab == 1) ...[
                if (completedTaskList.isNotEmpty) ...[
                  _sectionTitle(context, AppLocalizations.of(context)!.done),

                  const SizedBox(height: 10),

                  ...completedTaskList.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 10,
                      ),
                      child: _taskCard(task),
                    ),
                  ),
                ],

                if (completedTaskList.isEmpty)
                  EmptyState(
                    icon: Icons.check_circle_outline,
                    title: AppLocalizations.of(context)!.noCompletedTasks,
                    message: AppLocalizations.of(
                      context,
                    )!.noCompletedTasksMessage,
                  ),
              ] else ...[
                if (todayTasks.isNotEmpty) ...[
                  _sectionTitle(context, AppLocalizations.of(context)!.today),

                  const SizedBox(height: 10),

                  ...todayTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 10,
                      ),
                      child: _taskCard(task),
                    ),
                  ),
                ],

                if (tomorrowTasks.isNotEmpty) ...[
                  const SizedBox(height: 10),

                  _sectionTitle(
                    context,
                    '${AppLocalizations.of(context)!.tomorrow} - ${tomorrow.day}/${tomorrow.month}',
                  ),

                  const SizedBox(height: 10),

                  ...tomorrowTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 10,
                      ),
                      child: _taskCard(task),
                    ),
                  ),
                ],

                if (laterTasks.isNotEmpty) ...[
                  const SizedBox(height: 10),

                  _sectionTitle(
                    context,
                    AppLocalizations.of(context)!.upcomingTasks,
                  ),

                  const SizedBox(height: 10),

                  ...laterTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 10,
                      ),
                      child: _taskCard(task),
                    ),
                  ),
                ],

                if (tasks.isEmpty)
                  EmptyState(
                    icon: Icons.task_alt,
                    title: AppLocalizations.of(context)!.noTasksYet,
                    message: AppLocalizations.of(context)!.noTasksYetMessage,
                    buttonText: AppLocalizations.of(context)!.createTask,
                    onPressed: () async {
                      final result = await context.push('/Reminder');

                      if (result == true && mounted) {
                        context.read<TaskProvider>().loadTasks();
                      }
                    },
                  ),
              ],

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _taskCard(TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final time =
        '${task.scheduledAt.hour.toString().padLeft(2, '0')}:'
        '${task.scheduledAt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () {
        context.push('/ReminderDetails', extra: task);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColor.darkSurface : AppColor.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? .20 : .04),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final success = await context.read<TaskProvider>().updateTask(
                  TaskModel(
                    id: task.id,
                    title: task.title,
                    description: task.description,
                    scheduledAt: task.scheduledAt,
                    category: task.category,
                    priority: task.priority,
                    color: task.color,
                    isCompleted: !task.isCompleted,
                    repeat: task.repeat,
                    remindBefore: task.remindBefore,
                    createdAt: task.createdAt,
                    updatedAt: DateTime.now(),
                  ),
                );

                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.read<TaskProvider>().error ??
                            'حدث خطأ أثناء تحديث المهمة',
                      ),
                    ),
                  );
                }
              },
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
                      color: _getCategoryColor(task.category).withOpacity(.08),
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
            color: Colors.black.withOpacity(isDark ? 0.20 : 0.05),
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
