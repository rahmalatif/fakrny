import 'package:flutter/material.dart';
import 'package:untitled/l10n/app_localizations.dart';

import '../core/design/theme/app_color.dart';
import '../core/design/widgets/nav_bar.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  localizations.profile,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1F2937),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColor.Grad1, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.Grad1.withOpacity(0.18),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      getIntials("Rahma Ahmed"),
                      style: const TextStyle(
                        color: AppColor.Grad1,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  localizations.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Row(
                children: [
                  Expanded(
                    child: _container(value: "15", title: localizations.streak),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _container(
                      value: "89%",
                      title: localizations.progress,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _container(value: "127", title: localizations.task),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  localizations.settings,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _buildSettingTile(
                title: localizations.notification,
                icon: Icons.notifications_none_rounded,
                trailing: Switch(
                  value: true,
                  onChanged: null,
                  activeColor: AppColor.Grad1,
                ),
              ),

              _buildSettingTile(
                title: localizations.darkMode,
                icon: Icons.nightlight_outlined,
                trailing: Switch(
                  value: false,
                  onChanged: null,
                  activeColor: AppColor.Grad1,
                ),
              ),

              _buildSettingTile(
                title: localizations.lang,
                icon: Icons.language,
                trailing: const Text(
                  "العربية",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),

              _buildSettingTile(
                title: localizations.logout,
                icon: Icons.logout,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CustomNavBar(currentIndex: 3),
    );
  }

  static Widget _container({required String value, required String title}) {
    return Container(
      height: 80,
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
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  static Widget _buildSettingTile({
    required String title,
    required IconData icon,
    required Widget trailing,
  }) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.08)),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 20, color: AppColor.Grad1),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: Color(0xff374151)),
            ),
          ),

          trailing,
        ],
      ),
    );
  }
}
