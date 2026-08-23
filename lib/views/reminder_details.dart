import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

class ReminderDetailsView extends StatefulWidget {
  const ReminderDetailsView({super.key});

  @override
  State<ReminderDetailsView> createState() => _ReminderDetailsViewState();
}

class _ReminderDetailsViewState extends State<ReminderDetailsView> {
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FC),
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
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(.1),
            ),
          ),
          child: IconButton(
            onPressed: () {
              context.go('/Home');
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
            ),
          ),
        ),

        const Spacer(),

        Column(
          children: [
            Text(
              AppLocalizations.of(context)!.reminderDetails,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Reminder Details',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),

        const Spacer(),

        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(.1),
            ),
          ),
          child: IconButton(
            onPressed: () {
              _showMoreOptions();
            },
            icon: const Icon(
              Icons.more_horiz,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reminderHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
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
              color: Colors.deepPurple.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مراجعة تقرير المشروع',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Text(
                      'دراسة',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      'High',
                      style: TextStyle(
                        color: Colors.red.shade400,
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
            valueColor: Colors.red,
          ),

          _divider(),

          _infoRow(
            icon: Icons.category_outlined,
            title: AppLocalizations.of(context)!.category,
            value: 'دراسة',
            valueColor: Colors.deepPurple,
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
            color: Colors.grey.shade500,
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 15,
      endIndent: 15,
      color: Colors.grey.shade100,
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
              ? Colors.green
              : Colors.deepPurple,
          foregroundColor: Colors.white,
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _editReminder();
            },
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
            ),
            label: Text(
              AppLocalizations.of(context)!.edit,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: Colors.deepPurple.withOpacity(.15),
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
            ),
            label: Text(
              AppLocalizations.of(context)!.delete,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: Colors.red.withOpacity(.15),
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppLocalizations.of(context)!.deleteReminder,
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalizations.of(context)!.deleteReminderConfirmation,
            textAlign: TextAlign.center,
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
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
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
    showModalBottomSheet(
      context: context,
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
                leading: const Icon(Icons.edit_outlined),
                title: Text(
                  AppLocalizations.of(context)!.edit,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editReminder();
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: Text(
                  AppLocalizations.of(context)!.delete,
                  style: const TextStyle(
                    color: Colors.red,
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