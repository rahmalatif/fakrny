import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/core/design/theme/app_color.dart';
import 'package:untitled/core/design/widgets/tasks_contanier.dart';
import 'package:untitled/l10n/app_localizations.dart';

import '../core/design/widgets/nav_bar.dart';
import '../model/tasks.dart';
import '../services/auth_services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthServices authServices = AuthServices();

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

  String get userName {
    return authServices.currentUser?.displayName ?? 'User';
  }

  String getIntials(String name) {
    if (name.trim().isEmpty) return "";

    List<String> parts = name.trim().split(" ");

    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    return "${parts[0][0]}${parts[1][0]}".toUpperCase();
  }

  final List<Task> tasks = [
    Task(
      title: 'مراجعة تقرير المشروع',
      time: '10:00 ص',
      category: 'عمل',
      priority: 'أولوية عالية',
      color: RandomColor.getColorObject(Options(luminosity: Luminosity.light)),
    ),
    Task(
      title: 'مذاكرة Flutter',
      time: '12:00 م',
      category: 'دراسة',
      priority: 'متوسطة',
      color: RandomColor.getColorObject(Options(luminosity: Luminosity.light)),
    ),
    Task(
      title: 'الذهاب إلى الجيم',
      time: '5:00 م',
      category: 'رياضة',
      priority: 'منخفضة',
      color: RandomColor.getColorObject(Options(luminosity: Luminosity.light)),
    ),
    Task(
      title: 'قراءة كتاب',
      time: '7:00 م',
      category: 'شخصي',
      priority: 'متوسطة',
      color: RandomColor.getColorObject(Options(luminosity: Luminosity.light)),
    ),
    Task(
      title: 'مكالمة مع العميل',
      time: '9:00 م',
      category: 'عمل',
      priority: 'أولوية عالية',
      color: RandomColor.getColorObject(Options(luminosity: Luminosity.light)),
    ),
  ];

  final Set<int> completedTasks = {};

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
                        "${getGreeting(context)}, $userName",
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
                        )!.todayTasksNum(tasks.length),
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
                        getIntials(userName),
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
                        style: TextStyle(
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
                child: ListView.separated(
                  itemCount: tasks.length,

                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },

                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    final isCompleted = completedTasks.contains(index);

                    return TasksContanier(
                      title: task.title,
                      time: task.time,
                      category: task.category,
                      priority: task.priority,
                      color: task.color,
                      isCompleted: isCompleted,

                      onCheck: () {
                        setState(() {
                          if (isCompleted) {
                            completedTasks.remove(index);
                          } else {
                            completedTasks.add(index);
                          }
                        });
                      },

                      onTap: () {
                        context.go('/ReminderDetails');
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
        onPressed: () {},
        backgroundColor: AppColor.Grad3,
        child: const Icon(Icons.add, color: AppColor.textWhite),
      ),

      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }
}
