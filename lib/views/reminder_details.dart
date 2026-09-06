import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/l10n/app_localizations.dart';

import '../core/design/theme/app_color.dart';

class ReminderDetailsView extends StatefulWidget {
  const ReminderDetailsView({super.key});

  @override
  State<ReminderDetailsView> createState() => _ReminderDetailsViewState();
}

class _ReminderDetailsViewState extends State<ReminderDetailsView> {
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColor.darkBackground
          : AppColor.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Column(
            children: [
              _header(),

              const SizedBox(height: 18),

              _reminderHeader(),

              const SizedBox(height: 12),

              _infoSection(),

              const SizedBox(height: 15),

              _completeButton(),

              const SizedBox(height: 12),

              _actions(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? AppColor.darkSurface
                : AppColor.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppColor.darkCard
                  : AppColor.border.withOpacity(.1),
            ),
          ),
          child: IconButton(
            onPressed: () {
              context.go('/Home');
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: isDark
                  ? AppColor.textWhite
                  : AppColor.textPrimary,
            ),
          ),
        ),

        const Spacer(),

        Column(
          children: [
            Text(
              AppLocalizations.of(context)!.reminderDetails,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColor.textWhite
                    : AppColor.textPrimary,
              ),
            ),

            Text(
              'Reminder Details',
              style: TextStyle(
                fontSize: 9,
                color: isDark
                    ? AppColor.textHint
                    : AppColor.textSecondary,
              ),
            ),
          ],
        ),

        const Spacer(),

        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? AppColor.darkSurface
                : AppColor.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppColor.darkCard
                  : AppColor.border.withOpacity(.1),
            ),
          ),
          child: IconButton(
            onPressed: () {
              _showMoreOptions();
            },
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: isDark
                  ? AppColor.textWhite
                  : AppColor.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reminderHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColor.darkSurface
            : AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? .15 : .04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_outlined,
              color: AppColor.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مراجعة تقرير المشروع',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColor.textWhite
                        : AppColor.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Text(
                      'دراسة',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColor.textHint
                            : AppColor.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      'High',
                      style: TextStyle(
                        color: AppColor.error.withOpacity(.8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? AppColor.darkSurface
            : AppColor.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.calendar_today_outlined,
            title: AppLocalizations.of(context)!.date,
            value: 'السبت، 14 يونيو 2026',
          ),

          _divider(),

          _infoRow(
            icon: Icons.access_time,
            title: AppLocalizations.of(context)!.time,
            value: '10:00 ص',
          ),

          _divider(),

          _infoRow(
            icon: Icons.notifications_none,
            title: AppLocalizations.of(context)!.reminderBefore,
            value: '30 دقيقة',
          ),

          _divider(),

          _infoRow(
            icon: Icons.flag_outlined,
            title: AppLocalizations.of(context)!.priority,
            value: 'عالية',
            valueColor: AppColor.error,
          ),

          _divider(),

          _infoRow(
            icon: Icons.category_outlined,
            title: AppLocalizations.of(context)!.category,
            value: 'دراسة',
            valueColor: AppColor.primary,
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: isDark
                ? AppColor.textHint
                : AppColor.textSecondary,
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColor.textHint
                  : AppColor.textSecondary,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: valueColor ??
                  (isDark
                      ? AppColor.textWhite
                      : AppColor.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Divider(
      height: 1,
      indent: 15,
      endIndent: 15,
      color: isDark
          ? AppColor.darkCard
          : AppColor.divider,
    );
  }

  Widget _completeButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isCompleted = !isCompleted;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted
              ? AppColor.success
              : AppColor.primary,
          foregroundColor: AppColor.textWhite,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_outline
                  : Icons.check,
              size: 19,
            ),

            const SizedBox(width: 8),

            Text(
              isCompleted
                  ? AppLocalizations.of(context)!.completed
                  : AppLocalizations.of(context)!.markCompleted,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _editReminder();
            },
            icon: Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColor.primary,
            ),
            label: Text(
              AppLocalizations.of(context)!.edit,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.primary,
              backgroundColor: isDark
                  ? AppColor.darkSurface
                  : AppColor.surface,
              side: BorderSide(
                color: AppColor.primary.withOpacity(.15),
              ),
              minimumSize: const Size(
                double.infinity,
                50,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _deleteReminder();
            },
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppColor.error,
            ),
            label: Text(
              AppLocalizations.of(context)!.delete,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.error,
              backgroundColor: isDark
                  ? AppColor.darkSurface
                  : AppColor.surface,
              side: BorderSide(
                color: AppColor.error.withOpacity(.15),
              ),
              minimumSize: const Size(
                double.infinity,
                50,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _editReminder() {
    context.push('/Reminder');
  }

  void _deleteReminder() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark
              ? AppColor.darkSurface
              : AppColor.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppLocalizations.of(context)!.deleteReminder,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? AppColor.textWhite
                  : AppColor.textPrimary,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.deleteReminderConfirmation,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? AppColor.textHint
                  : AppColor.textSecondary,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.error,
                  foregroundColor: AppColor.textWhite,
                ),
                child: Text(
                  AppLocalizations.of(context)!.delete,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMoreOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? AppColor.darkSurface
          : AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.edit_outlined,
                  color: isDark
                      ? AppColor.textWhite
                      : AppColor.textPrimary,
                ),
                title: Text(
                  AppLocalizations.of(context)!.edit,
                  style: TextStyle(
                    color: isDark
                        ? AppColor.textWhite
                        : AppColor.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editReminder();
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColor.error,
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(
                    color: AppColor.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteReminder();
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}