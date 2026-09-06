import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design/theme/app_color.dart';
import '../core/design/widgets/nav_bar.dart';
import '../l10n/app_localizations.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  int selectedTab = 0;

  final List<TaskItem> todayTasks = [
    TaskItem(
      title: 'تحضير العرض التقديمي',
      time: '10:00',
      category: 'دراسة',
      categoryColor: AppColor.primary,
      completed: false,
    ),
    TaskItem(
      title: 'مذاكرة Flutter',
      time: '12:00',
      category: 'دراسة',
      categoryColor: AppColor.primary,
      completed: true,
    ),
    TaskItem(
      title: 'غداء مع الفريق',
      time: '1:00',
      category: 'عمل',
      categoryColor: AppColor.info,
      completed: false,
    ),
  ];

  final List<TaskItem> tomorrowTasks = [
    TaskItem(
      title: 'مراجعة التصميم الجديد',
      time: '11:00',
      category: 'عمل',
      categoryColor: AppColor.info,
      completed: false,
    ),
  ];

  final List<TaskItem> laterTasks = [
    TaskItem(
      title: 'التخطيط للرحلة',
      time: '5:00',
      category: 'شخصي',
      categoryColor: AppColor.error,
      completed: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColor.darkBackground
          : AppColor.background,

      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),

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

                    const Spacer(),

                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor.Grad1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColor.darkCard.withOpacity(.1)
                              : AppColor.border.withOpacity(.1),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          context.go('/');
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                          color: AppColor.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),

                  color: isDark
                      ? AppColor.darkSurface
                      : AppColor.secondary,
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
                      title: '12',
                    ),
                    _container(
                      context: context,
                      value: AppLocalizations.of(context)!.completedTasks,
                      title: '5',
                    ),
                    _container(
                      context: context,
                      value: AppLocalizations.of(context)!.pendingTasks,
                      title: '7',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _sectionTitle(
                context,
                AppLocalizations.of(context)!.today,
              ),

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

              const SizedBox(height: 10),

              _sectionTitle(
                context,
                'غداً - الأحد 15 يونيو',
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

              const SizedBox(height: 10),

              _sectionTitle(
                context,
                'الاثنين 16 يونيو',
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
            color: isDark
                ? AppColor.textWhite
                : AppColor.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _taskCard(TaskItem task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        context.push('/ReminderDetails');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColor.darkSurface
              : AppColor.surface,

          borderRadius: BorderRadius.circular(12),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isDark ? .20 : .04,
              ),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  task.completed = !task.completed;
                });
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: task.completed
                      ? AppColor.success
                      : isDark
                      ? AppColor.darkCard
                      : AppColor.surface,

                  border: Border.all(
                    color: task.completed
                        ? AppColor.success
                        : isDark
                        ? AppColor.disabled
                        : AppColor.border,
                  ),
                ),

                child: task.completed
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

                            color: task.completed
                                ? isDark
                                ? AppColor.textHint
                                : AppColor.textSecondary
                                : isDark
                                ? AppColor.textWhite
                                : AppColor.textPrimary,

                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),

                      Text(
                        '${task.time}',
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
                      color: task.categoryColor.withOpacity(.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      task.category,
                      style: TextStyle(
                        color: task.categoryColor,
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
        color: isDark
            ? AppColor.darkCard
            : AppColor.surface,

        borderRadius: BorderRadius.circular(10),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? 0.20 : 0.05,
            ),
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
              color: isDark
                  ? AppColor.textHint
                  : AppColor.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: isDark
                  ? AppColor.textWhite
                  : AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskItem {
  final String title;
  final String time;
  final String category;
  final Color categoryColor;
  bool completed;

  TaskItem({
    required this.title,
    required this.time,
    required this.category,
    required this.categoryColor,
    required this.completed,
  });
}