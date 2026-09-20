import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/design/theme/app_color.dart';
import 'package:untitled/core/design/widgets/tasks_contanier.dart';
import 'package:untitled/l10n/app_localizations.dart';
import 'package:untitled/provider/task_provider.dart';
import '../core/design/widgets/empty_states.dart';
import '../core/design/widgets/nav_bar.dart';
import '../model/tasks.dart';
import '../model/user_model.dart';
import '../services/auth_services.dart';
import '../services/user_firestore_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthServices authServices = AuthServices();
  final UserFirestoreService userFirestoreService = UserFirestoreService();

  UserModel? user;
  bool isUserLoading = true;

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

  @override
  void initState() {
    super.initState();
    loadUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
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

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final todayTasks = taskProvider.todayTasks;
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
                child: taskProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : todayTasks.isEmpty
                    ? EmptyState(
                        icon: taskProvider.tasks.isEmpty
                            ? Icons.task_alt
                            : Icons.event_available,
                        title: taskProvider.tasks.isEmpty
                            ? AppLocalizations.of(context)!.noTasksYet
                            : AppLocalizations.of(context)!.noTasksToday,
                        message: taskProvider.tasks.isEmpty
                            ? AppLocalizations.of(context)!.noTasksYetMessage
                            : AppLocalizations.of(context)!.noTasksTodayMessage,
                        buttonText: taskProvider.tasks.isEmpty
                            ? AppLocalizations.of(context)!.createTask
                            : AppLocalizations.of(context)!.createTask,
                        onPressed: () async {
                          final result = await context.push('/Reminder');

                          if (result == true && mounted) {
                            context.read<TaskProvider>().loadTasks();
                          }
                        },
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
                              context.read<TaskProvider>().toggleTask(task);
                            },

                            onTap: () async {
                              final taskProvider = context.read<TaskProvider>();

                              final result = await context.push(
                                '/ReminderDetails',
                                extra: task,
                              );

                              if (!mounted) return;

                              if (result == true) {
                                await taskProvider.loadTasks();
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
            context.read<TaskProvider>().loadTasks();
          }
        },

        backgroundColor: AppColor.Grad3,

        child: const Icon(Icons.add, color: AppColor.textWhite),
      ),

      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }
}
