import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled/l10n/app_localizations.dart';

import '../core/design/theme/app_color.dart';
import '../core/design/widgets/nav_bar.dart';
import '../model/tasks.dart';
import '../provider/task_provider.dart';

class CalenderView extends StatefulWidget {
  const CalenderView({super.key});

  @override
  State<CalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 20),
              _buildTitle(isDark),
              const SizedBox(height: 30),
              _buildCalendar(),
              const SizedBox(height: 25),
              _buildSelectedDayTasks(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColor.grad3,
        child: const Icon(Icons.add, color: AppColor.textWhite),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  Widget _buildTitle(bool isDark) {
    final l10n = AppLocalizations.of(context)!;

    return Text(
      l10n.calender,
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColor.textWhite : AppColor.textPrimary,
      ),
    );
  }

  Widget _buildCalendar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final taskProvider = context.watch<TaskProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurface : AppColor.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TableCalendar<TaskModel>(
        locale: l10n.calenderlang,

        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),

        focusedDay: _focusedDay,
        currentDay: DateTime.now(),

        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },

        eventLoader: (day) {
          return taskProvider.tasksForDate(day);
        },

        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },

        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },

        calendarBuilders: CalendarBuilders<TaskModel>(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) {
              return null;
            }

            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 2),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColor.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,

          titleTextStyle: TextStyle(
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),

          leftChevronIcon: Icon(
            Icons.chevron_left,
            size: 20,
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
          ),

          rightChevronIcon: Icon(
            Icons.chevron_right,
            size: 20,
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
          ),
        ),

        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 11,
            color: isDark ? AppColor.textHint : AppColor.textSecondary,
          ),
          weekendStyle: TextStyle(
            fontSize: 11,
            color: isDark ? AppColor.textHint : AppColor.textSecondary,
          ),
        ),

        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,

          defaultTextStyle: TextStyle(
            fontSize: 11,
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
          ),

          weekendTextStyle: TextStyle(
            fontSize: 11,
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
          ),

          todayDecoration: const BoxDecoration(
            color: AppColor.transparent,
            shape: BoxShape.circle,
          ),

          todayTextStyle: TextStyle(
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
            fontSize: 11,
          ),

          selectedDecoration: const BoxDecoration(
            color: AppColor.primary,
            shape: BoxShape.circle,
          ),

          selectedTextStyle: const TextStyle(
            color: AppColor.textWhite,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),

          cellMargin: const EdgeInsets.all(4),
        ),
      ),
    );
  }

  Widget _buildSelectedDayTasks() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final taskProvider = context.watch<TaskProvider>();

    final selectedDay = _selectedDay ?? DateTime.now();

    final selectedTasks = taskProvider.tasksForDate(selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.todaysSchadule,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
          ),
        ),

        const SizedBox(height: 15),

        if (selectedTasks.isEmpty)
          _buildEmptyTasksState()
        else
          ...selectedTasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _taskCard(task),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyTasksState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkCard : AppColor.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 40,
            color: isDark ? AppColor.textHint : AppColor.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.noTasks,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColor.textHint : AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkCard : AppColor.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.task_alt,
              color: AppColor.textWhite,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  task.title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColor.textWhite : AppColor.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _formatTime(task.scheduledAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColor.textHint : AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour == 0
        ? 12
        : dateTime.hour;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
