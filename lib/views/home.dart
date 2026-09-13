import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/core/design/theme/app_color.dart';
import 'package:untitled/core/design/widgets/tasks_contanier.dart';
import 'package:untitled/l10n/app_localizations.dart';

import '../core/design/widgets/nav_bar.dart';
import '../model/tasks.dart';
import '../model/user_model.dart';
import '../services/auth_services.dart';
import '../services/user_firestore_service.dart';
import '../services/task_firestore_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthServices authServices = AuthServices();
  final UserFirestoreService userFirestoreService = UserFirestoreService();
  final TaskFirestoreService taskFirestoreService = TaskFirestoreService();

  UserModel? user;

  List<TaskModel> tasks = [];

  bool isUserLoading = true;
  bool isTasksLoading = true;

  Future<void> loadUser() async {
    final currentUser = authServices.currentUser;

    if (currentUser == null) {
      if (mounted) {
        setState(() {
          isUserLoading = false;
        });
      }
      return;
    }

    final userData = await userFirestoreService.getUser(currentUser.uid);

    if (!mounted) return;

    setState(() {
      user = userData;
      isUserLoading = false;
    });
  }

  Future<void> loadTasks() async {
    final currentUser = authServices.currentUser;

    if (currentUser == null) {
      if (mounted) {
        setState(() {
          isTasksLoading = false;
        });
      }
      return;
    }

    try {
      final userTasks = await taskFirestoreService.getTasks(currentUser.uid);

      if (!mounted) return;

      setState(() {
        tasks = userTasks;
        isTasksLoading = false;
      });
    } catch (e) {
      debugPrint('Load Tasks Error: $e');

      if (!mounted) return;

      setState(() {
        isTasksLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    loadUser();
    loadTasks();
  }

  String get firstName {
    final name = user?.name.trim() ?? '';

    if (name.isEmpty) {
      return 'User';
    }

    return name.split(RegExp(r'\s+')).first;
  }

  String getInitials(String name) {
    if (name.trim().isEmpty) {
      return '';
    }

    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;

    final localizations = AppLocalizations.of(context)!;

    if (hour >= 5 && hour < 12) {
      return localizations.goodMorning;
    } else if (hour >= 12 && hour < 17) {
      return localizations.goodAfternoon;
    } else if (hour >= 17 && hour < 21) {
      return localizations.goodEvening;
    } else {
      return localizations.goodNight;
    }
  }

  Color getTaskColor(String color) {
    if (color.isEmpty) {
      return AppColor.primary;
    }

    try {
      return Color(int.parse(color, radix: 16));
    } catch (_) {
      return AppColor.primary;
    }
  }

  List<TaskModel> get todayTasks {
    final now = DateTime.now();

    return tasks.where((task) {
      return task.scheduledAt.year == now.year &&
          task.scheduledAt.month == now.month &&
          task.scheduledAt.day == now.day;
    }).toList();
  }

  Future<void> toggleTask(TaskModel task) async {
    final currentUser = authServices.currentUser;

    if (currentUser == null) return;

    final newValue = !task.isCompleted;

    setState(() {
      final index = tasks.indexWhere((element) => element.id == task.id);

      if (index != -1) {
        tasks[index] = TaskModel(
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
      }
    });

    await taskFirestoreService.updateTask(
      uid: currentUser.uid,
      taskId: task.id,
      data: {'isCompleted': newValue},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 14, right: 14),

          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        '${getGreeting(context)}, $firstName',

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,

                          color: isDark
                              ? AppColor.textWhite
                              : AppColor.textPrimary,
                        ),
                      ),

                      Text(
                        AppLocalizations.of(
                          context,
                        )!.todayTasksNum(todayTasks.length),

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,

                          color: isDark
                              ? AppColor.textHint
                              : AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: () {
                      context.go('/Profile');
                    },

                    child: CircleAvatar(
                      backgroundColor: AppColor.Grad3,

                      child: Text(
                        getInitials(user?.name ?? 'User'),

                        style: const TextStyle(
                          color: AppColor.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(8.0),

                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.today,

                      style: TextStyle(
                        color: isDark
                            ? AppColor.textWhite
                            : AppColor.textPrimary,

                        fontWeight: FontWeight.bold,

                        fontSize: 24,
                      ),
                    ),

                    const Spacer(),

                    TextButton(
                      onPressed: () {
                        context.go('/Tasks');
                      },

                      child: Text(
                        AppLocalizations.of(context)!.showAll,

                        style: const TextStyle(
                          color: AppColor.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: isTasksLoading
                    ? const Center(child: CircularProgressIndicator())
                    : todayTasks.isEmpty
                    ? Center(
                        child: Text(
                          'No tasks for today',
                          style: TextStyle(
                            color: isDark
                                ? AppColor.textHint
                                : AppColor.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: todayTasks.length,

                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 10);
                        },

                        itemBuilder: (context, index) {
                          final task = todayTasks[index];

                          return TasksContanier(
                            title: task.title,
                            category: task.category,

                            priority: task.priority,

                            color: getTaskColor(task.color),

                            isCompleted: task.isCompleted,

                            onCheck: () {
                              toggleTask(task);
                            },

                            onTap: () async {
                              final result = await context.push(
                                '/ReminderDetails',
                                extra: task,
                              );

                              if (result == true && mounted) {
                                await loadTasks();
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/Reminder');

          if (result == true && mounted) {
            await loadTasks();
          }
        },

        backgroundColor: AppColor.Grad3,

        child: const Icon(Icons.add, color: AppColor.textWhite),
      ),

      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }
}
