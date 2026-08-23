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
      categoryColor: Colors.deepPurple,
      completed: false,
    ),
    TaskItem(
      title: 'مذاكرة Flutter',
      time: '12:00',
      category: 'دراسة',
      categoryColor: Colors.deepPurple,
      completed: true,
    ),
    TaskItem(
      title: 'غداء مع الفريق',
      time: '1:00',
      category: 'عمل',
      categoryColor: Colors.blue,
      completed: false,
    ),
  ];

  final List<TaskItem> tomorrowTasks = [
    TaskItem(
      title: 'مراجعة التصميم الجديد',
      time: '11:00',
      category: 'عمل',
      categoryColor: Colors.blue,
      completed: false,
    ),
  ];

  final List<TaskItem> laterTasks = [
    TaskItem(
      title: 'التخطيط للرحلة',
      time: '5:00',
      category: 'شخصي',
      categoryColor: Colors.red,
      completed: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
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
                        border: Border.all(color: Colors.grey.withOpacity(.1)),
                      ),
                      child: IconButton(
                        onPressed: () {
                          context.go('/');
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.white,
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
                  color: Colors.grey.shade100,
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
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)!.all,
                            style: TextStyle(
                              color: selectedTab == 0
                                  ? Colors.white
                                  : Colors.grey.shade700,
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
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)!.done,
                            style: TextStyle(
                              color: selectedTab == 1
                                  ? Colors.white
                                  : Colors.grey.shade700,
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
                      value: AppLocalizations.of(context)!.totalTasks,
                      title: '12',
                    ),
                    _container(
                      value: AppLocalizations.of(context)!.completedTasks,
                      title: '5',
                    ),
                    _container(
                      value: AppLocalizations.of(context)!.pendingTasks,
                      title: '7',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _sectionTitle(AppLocalizations.of(context)!.today),

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

              _sectionTitle('غداً - الأحد 15 يونيو'),

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

              _sectionTitle('الاثنين 16 يونيو'),

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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _taskCard(TaskItem task) {
    return GestureDetector(
      onTap: () {
        context.push('/ReminderDetails');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
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
                  color: task.completed ? Colors.green : Colors.white,
                  border: Border.all(
                    color: task.completed ? Colors.green : Colors.grey.shade300,
                  ),
                ),
                child: task.completed
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
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
                                ? Colors.grey
                                : Colors.black87,
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
                          color: Colors.grey.shade500,
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

  static Widget _container({required String value, required String title}) {
    return Container(
      height: 80,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            style: const TextStyle(fontSize: 10, color: Colors.black),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
