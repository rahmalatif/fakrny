import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/design/theme/lang_controller.dart';
import 'package:untitled/core/design/theme/theme_controller.dart';
import 'package:untitled/l10n/app_localizations.dart';
import '../core/design/theme/app_color.dart';
import '../core/design/widgets/nav_bar.dart';
import '../core/design/widgets/snack_bar.dart';
import '../model/user_model.dart';
import '../provider/task_provider.dart';
import '../services/auth_services.dart';
import '../services/user_firestore_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthServices authServices = AuthServices();
  final UserFirestoreService userFirestoreService = UserFirestoreService();

  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  Future<void> _loadProfile() async {
    final currentUser = authServices.currentUser;

    if (currentUser == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final userData = await userFirestoreService.getUser(currentUser.uid);

      if (!mounted) return;

      setState(() {
        user = userData;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
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

  int get totalTasks {
    return context.read<TaskProvider>().tasks.length;
  }

  int get completedTasks {
    return context
        .read<TaskProvider>()
        .tasks
        .where((task) => task.isCompleted)
        .length;
  }

  int get progressPercentage {
    if (totalTasks == 0) {
      return 0;
    }

    return ((completedTasks / totalTasks) * 100).round();
  }

  int get streak {
    final tasks = context.read<TaskProvider>().tasks;

    final completedDays = <DateTime>{};

    for (final task in tasks) {
      if (!task.isCompleted) continue;

      final date = DateTime(
        task.scheduledAt.year,
        task.scheduledAt.month,
        task.scheduledAt.day,
      );

      completedDays.add(date);
    }

    if (completedDays.isEmpty) {
      return 0;
    }

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    if (!completedDays.contains(today)) {
      return 0;
    }

    int currentStreak = 1;
    DateTime expectedDay = today.subtract(const Duration(days: 1));

    while (completedDays.contains(expectedDay)) {
      currentStreak++;

      expectedDay = expectedDay.subtract(const Duration(days: 1));
    }

    return currentStreak;
  }

  Future<void> _logout() async {
    final localizations = AppLocalizations.of(context)!;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? AppColor.darkSurface : AppColor.surface,
          title: Text(
            localizations.logout,
            style: TextStyle(
              color: isDark ? AppColor.textWhite : AppColor.textPrimary,
            ),
          ),
          content: Text(
            localizations.logoutConfirmation,
            style: TextStyle(
              color: isDark ? AppColor.textHint : AppColor.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                localizations.logout,
                style: const TextStyle(color: AppColor.error),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      context.go('/Login');
    } catch (e) {
      if (!mounted) return;

      SnackBarHelper.show(
        context,
        message: e.toString(),
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LangController>();
    final isDark = themeController.isDark;
    final isArabic = localeController.locale.languageCode == 'ar';
    final displayName = user?.name.trim().isNotEmpty == true
        ? user!.name
        : 'User';
    final displayEmail = user?.email ?? '';


    return Scaffold(
      backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  localizations.profile,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColor.textWhite : AppColor.textPrimary,
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
                    color: isDark ? AppColor.darkSurface : AppColor.surface,
                    border: Border.all(color: AppColor.grad1, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.grad1.withValues(alpha: 0.18),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.grad1,
                            ),
                          )
                        : Text(
                            getInitials(displayName),
                            style: const TextStyle(
                              color: AppColor.grad1,
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
                  displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? AppColor.textWhite : AppColor.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              if (displayEmail.isNotEmpty)
                Center(
                  child: Text(
                    displayEmail,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColor.textHint
                          : AppColor.textSecondary,
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: profileContainer(
                      context: context,
                      value: '$streak',
                      title: localizations.streak,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: profileContainer(
                      context: context,
                      value: '$progressPercentage%',
                      title: localizations.progress,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: profileContainer(
                      context: context,
                      value: '$totalTasks',
                      title: localizations.task,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Align(
                alignment: isArabic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  localizations.settings,
                  style: TextStyle(
                    color: isDark ? AppColor.textWhite : AppColor.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              buildSettingTile(
                context: context,
                title: localizations.darkMode,
                icon: Icons.nightlight_outlined,
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) {
                    themeController.toggleTheme();
                  },
                  activeThumbColor: AppColor.grad1,
                ),
              ),

              buildSettingTile(
                context: context,
                title: localizations.lang,
                icon: Icons.language,
                trailing: Text(
                  isArabic ? 'العربية' : 'English',
                  style: TextStyle(
                    color: isDark ? AppColor.textHint : AppColor.textSecondary,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  localeController.toggleLocale();
                },
              ),

              buildSettingTile(
                context: context,
                title: localizations.logout,
                icon: Icons.logout,
                trailing: Icon(
                  isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                  size: 14,
                  color: isDark ? AppColor.textHint : AppColor.textSecondary,
                ),
                onTap: _logout,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 3),
    );
  }
}

Widget profileContainer({
  required BuildContext context,
  required String value,
  required String title,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    height: 80,
    decoration: BoxDecoration(
      color: isDark ? AppColor.darkCard : AppColor.surface,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.20)
              : Colors.black.withValues(alpha: 0.05),
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
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppColor.textHint : AppColor.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

Widget buildSettingTile({
  required BuildContext context,
  required String title,
  required IconData icon,
  required Widget trailing,
  VoidCallback? onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

  return InkWell(
    onTap: onTap,
    child: Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurface : AppColor.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColor.darkCard.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Icon(icon, size: 20, color: AppColor.grad1),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColor.textWhite : AppColor.textPrimary,
              ),
            ),
          ),

          trailing,
        ],
      ),
    ),
  );
}
