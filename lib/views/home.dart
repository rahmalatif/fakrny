import 'package:flutter/material.dart';
import 'package:untitled/core/design/theme/app_color.dart';
import 'package:untitled/l10n/app_localizations.dart';

import '../core/design/theme/app_gradiant.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 35.0, left: 14),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      "${getGreeting(context)}, Rahma",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.todayTasksNum(5),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: CircleAvatar(
                    backgroundColor: AppColor.Grad3,
                    child: Text(
                      getIntials("Rahma Ahmed"),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            Container(
              height: MediaQuery.of(context).size.height * .2,
              width: MediaQuery.of(context).size.height * .4,
              decoration: const BoxDecoration(gradient: AppGradient.primary),
            ),
          ],
        ),
      ),
    );
  }
}
