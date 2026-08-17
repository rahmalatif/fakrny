import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:untitled/core/design/theme/app_color.dart';
import 'package:untitled/core/design/widgets/tasks_contanier.dart';
import 'package:untitled/l10n/app_localizations.dart';

import '../core/design/theme/app_gradiant.dart';
import '../core/design/widgets/nav_bar.dart';
import '../model/tasks.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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

  String getIntials(String name) {
    if (name.trim().isEmpty) return "";

    List<String> parts = name.trim().split(" ");

    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    return "${parts[0][0]}${parts[1][0]}".toUpperCase();
  }

  static final List<Task> tasks = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        "${getGreeting(context)}, Rahma",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),

                      Text(
                        AppLocalizations.of(
                          context,
                        )!.todayTasksNum(tasks.length),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  CircleAvatar(
                    backgroundColor: AppColor.Grad3,
                    child: Text(
                      getIntials("Rahma Ahmed"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        AppLocalizations.of(context)!.showAll,
                        style: TextStyle(
                          color: Colors.deepPurple,
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

                    return TasksContanier(
                      title: task.title,
                      time: task.time,
                      category: task.category,
                      priority: task.priority,
                      color: task.color,
                      onTap: () {
                        print(task.title);
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
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColor.Grad3,
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }
}
