import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/design/theme/app_color.dart';
import '../core/design/widgets/empty_states.dart';
import '../core/design/widgets/nav_bar.dart';
import '../l10n/app_localizations.dart';
import '../model/tasks.dart';
import '../provider/task_provider.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  int selectedTab = 0;

  static const int _futureDays = 30;
  static const int _pageSize = 10;

  int _visibleTasksCount = _pageSize;

  final Set<String> _dismissedOccurrenceKeys = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskProvider>().loadTasks();
    });
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _getOccurrenceKey(TaskModel task, DateTime date) {
    return '${task.id}_${date.year}_${date.month}_${date.day}';
  }

  bool _occursOnDate(TaskModel task, DateTime date) {
    final target = _dateOnly(date);
    final start = _dateOnly(task.scheduledAt);

    if (target.isBefore(start)) return false;

    if (task.repeatEndDate != null) {
      final end = _dateOnly(task.repeatEndDate!);
      if (target.isAfter(end)) return false;
    }

    switch (task.repeat.toLowerCase().trim()) {
      case 'none':
        return target == start;

      case 'daily':
        return true;

      case 'weekly':
        return target.weekday == start.weekday;

      case 'monthly':
        final lastDay = DateTime(target.year, target.month + 1, 0).day;
        if (start.day > lastDay) {
          return target.day == lastDay;
        }
        return target.day == start.day;

      case 'custom':
        return task.repeatDays.contains(target.weekday);

      default:
        return target == start;
    }
  }

  List<_TaskOccurrence> _buildOccurrences(
      List<TaskModel> tasks,
      TaskProvider provider,
      ) {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final lastDate = today.add(const Duration(days: _futureDays));

    final occurrences = <_TaskOccurrence>[];

    for (final task in tasks) {
      final taskStartDate = _dateOnly(task.scheduledAt);

      if (taskStartDate.isAfter(lastDate)) {
        continue;
      }

      if (task.repeat == 'none') {
        final isCompleted = provider.isTaskCompletedOnDate(task, taskStartDate);

        if (taskStartDate.isBefore(today) && isCompleted) {
          continue;
        }

        final key = _getOccurrenceKey(task, taskStartDate);
        if (_dismissedOccurrenceKeys.contains(key)) {
          continue;
        }

        occurrences.add(
          _TaskOccurrence(
            task: task,
            date: taskStartDate,
            isCompleted: isCompleted,
          ),
        );

        continue;
      }

      for (var d = today.subtract(const Duration(days: 7));
      d.isBefore(today);
      d = d.add(const Duration(days: 1))) {
        final key = _getOccurrenceKey(task, d);
        if (_dismissedOccurrenceKeys.contains(key)) {
          continue;
        }

        if (_occursOnDate(task, d) && !provider.isTaskCompletedOnDate(task, d)) {
          occurrences.add(
            _TaskOccurrence(
              task: task,
              date: d,
              isCompleted: false,
            ),
          );
        }
      }

      final effectiveStartDate =
      taskStartDate.isBefore(today) ? today : taskStartDate;

      var date = effectiveStartDate;

      while (!date.isAfter(lastDate)) {
        if (_occursOnDate(task, date)) {
          occurrences.add(
            _TaskOccurrence(
              task: task,
              date: date,
              isCompleted: provider.isTaskCompletedOnDate(task, date),
            ),
          );
        }

        date = date.add(const Duration(days: 1));
      }
    }

    occurrences.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) {
        return dateComparison;
      }

      final aMinutes =
          a.task.scheduledAt.hour * 60 + a.task.scheduledAt.minute;
      final bMinutes =
          b.task.scheduledAt.hour * 60 + b.task.scheduledAt.minute;

      return aMinutes.compareTo(bMinutes);
    });

    return occurrences;
  }

  TaskModel _buildTaskWithNewSchedule(
      TaskModel original, DateTime newScheduledAt) {
    return TaskModel(
      id: original.id,
      title: original.title,
      description: original.description,
      scheduledAt: newScheduledAt,
      category: original.category,
      priority: original.priority,
      color: original.color,
      isCompleted: original.isCompleted,
      completedDates: List<String>.from(original.completedDates),
      repeat: original.repeat,
      repeatDays: List<int>.from(original.repeatDays),
      remindBefore: original.remindBefore,
      createdAt: original.createdAt,
      updatedAt: DateTime.now(),
      repeatEndDate: original.repeatEndDate,
    );
  }

  Future<void> _rescheduleTaskToDateTime(
      _TaskOccurrence occurrence,
      DateTime targetDate, {
        TimeOfDay? targetTime,
      }) async {
    final currentScheduled = occurrence.task.scheduledAt;

    final hour = targetTime?.hour ?? currentScheduled.hour;
    final minute = targetTime?.minute ?? currentScheduled.minute;

    final newScheduledAt = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );

    final updatedTask =
    _buildTaskWithNewSchedule(occurrence.task, newScheduledAt);
    final provider = context.read<TaskProvider>();
    final lang = Localizations.localeOf(context).languageCode;

    final oldKey = _getOccurrenceKey(occurrence.task, occurrence.date);
    setState(() {
      _dismissedOccurrenceKeys.add(oldKey);
    });

    final success = await provider.updateTask(
      updatedTask,
      languageCode: lang,
    );

    if (!mounted) return;

    if (!success && provider.error != null) {
      setState(() {
        _dismissedOccurrenceKeys.remove(oldKey);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: AppColor.error,
        ),
      );
      return;
    }

    final formattedDate =
        '${targetDate.day.toString().padLeft(2, '0')}/${targetDate.month.toString().padLeft(2, '0')}/${targetDate.year}';
    final formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    final isAr = lang == 'ar';
    final msg = isAr
        ? 'تمت إعادة جدولة "${occurrence.task.title}" إلى $formattedDate في $formattedTime'
        : 'Rescheduled "${occurrence.task.title}" to $formattedDate at $formattedTime';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _pickCustomRescheduleDateAndTime(
      _TaskOccurrence occurrence) async {
    final now = DateTime.now();
    final today = _dateOnly(now);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      locale: Localizations.localeOf(context),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColor.primary,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final initialTime = TimeOfDay(
      hour: occurrence.task.scheduledAt.hour,
      minute: occurrence.task.scheduledAt.minute,
    );

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: Localizations.localeOf(context),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColor.primary,
                brightness: Theme.of(context).brightness,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (!mounted) return;

    await _rescheduleTaskToDateTime(
      occurrence,
      pickedDate,
      targetTime: pickedTime ?? initialTime,
    );
  }

  String _getLocalizedCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;

    switch (category.toLowerCase().trim()) {
      case 'work':
      case 'عمل':
        return l10n.work;

      case 'study':
      case 'دراسة':
      case 'مذاكرة':
        return l10n.study;

      case 'health':
      case 'صحة':
        return l10n.health;

      case 'other':
      case 'أخرى':
      case 'اخرى':
        return l10n.other;

      default:
        return category;
    }
  }

  String _getLocalizedPriority(BuildContext context, String priority) {
    final l10n = AppLocalizations.of(context)!;

    switch (priority.toLowerCase().trim()) {
      case 'high':
      case 'عالية':
      case 'مرتفعة':
        return l10n.high;

      case 'medium':
      case 'متوسطة':
        return l10n.medium;

      case 'low':
      case 'منخفضة':
        return l10n.low;

      default:
        return priority;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase().trim()) {
      case 'study':
      case 'دراسة':
      case 'مذاكرة':
        return const Color(0xFF8B5CF6);

      case 'work':
      case 'عمل':
        return const Color(0xFF3B82F6);

      case 'health':
      case 'صحة':
        return const Color(0xFF22C55E);

      case 'other':
      case 'أخرى':
      case 'اخرى':
        return const Color(0xFFF59E0B);

      default:
        return AppColor.primary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase().trim()) {
      case 'high':
      case 'عالية':
      case 'مرتفعة':
        return AppColor.error;

      case 'medium':
      case 'متوسطة':
        return Colors.amber;

      case 'low':
      case 'منخفضة':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = context.watch<TaskProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final today = _dateOnly(DateTime.now());

    if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const CustomNavBar(currentIndex: 1),
      );
    }

    if (taskProvider.error != null && taskProvider.tasks.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              taskProvider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColor.textWhite : AppColor.textPrimary,
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CustomNavBar(currentIndex: 1),
      );
    }

    final allOccurrences = _buildOccurrences(taskProvider.tasks, taskProvider);

    final completedOccurrences = allOccurrences
        .where((occurrence) => occurrence.isCompleted)
        .toList()
      ..sort((a, b) {
        final dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) return dateComparison;

        final aMinutes =
            a.task.scheduledAt.hour * 60 + a.task.scheduledAt.minute;
        final bMinutes =
            b.task.scheduledAt.hour * 60 + b.task.scheduledAt.minute;
        return bMinutes.compareTo(aMinutes);
      });

    final pendingOccurrences = allOccurrences
        .where((occurrence) => !occurrence.isCompleted)
        .toList();

    final displayedOccurrences = selectedTab == 0
        ? allOccurrences
        : completedOccurrences;

    final visibleOccurrences = displayedOccurrences
        .take(_visibleTasksCount)
        .toList();

    final overdueOccurrences = visibleOccurrences
        .where((o) => _dateOnly(o.date).isBefore(today) && !o.isCompleted)
        .toList();

    final todayOccurrences = visibleOccurrences
        .where((o) => _dateOnly(o.date) == today)
        .toList();

    final upcomingOccurrences = visibleOccurrences
        .where((o) => _dateOnly(o.date).isAfter(today))
        .toList();

    final pastCompletedOccurrences = visibleOccurrences
        .where((o) => _dateOnly(o.date).isBefore(today) && o.isCompleted)
        .toList();

    final hasMoreTasks =
        displayedOccurrences.length > visibleOccurrences.length;

    final overdueText = isAr ? 'متأخرة' : 'Overdue';
    final todayText = isAr ? 'اليوم' : 'Today';
    final upcomingText = isAr ? 'القادمة' : 'Upcoming';
    final pastCompletedText = isAr ? 'مكتملة سابقة' : 'Past Completed';

    return Scaffold(
      backgroundColor: isDark ? AppColor.darkBackground : AppColor.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Text(
                    l10n.tasks,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColor.textWhite : AppColor.textPrimary,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: isDark ? AppColor.darkSurface : AppColor.secondary,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              selectedTab = 0;
                              _visibleTasksCount = _pageSize;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedTab == 0
                                  ? AppColor.grad1
                                  : AppColor.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.all,
                              style: TextStyle(
                                color: selectedTab == 0
                                    ? AppColor.textWhite
                                    : isDark
                                    ? AppColor.textHint
                                    : AppColor.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              selectedTab = 1;
                              _visibleTasksCount = _pageSize;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedTab == 1
                                  ? AppColor.grad1
                                  : AppColor.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.done,
                              style: TextStyle(
                                color: selectedTab == 1
                                    ? AppColor.textWhite
                                    : isDark
                                    ? AppColor.textHint
                                    : AppColor.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    _container(
                      context: context,
                      value: l10n.totalTasks,
                      title: allOccurrences.length.toString(),
                    ),
                    _container(
                      context: context,
                      value: l10n.completedTasks,
                      title: completedOccurrences.length.toString(),
                    ),
                    _container(
                      context: context,
                      value: l10n.pendingTasks,
                      title: pendingOccurrences.length.toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (overdueOccurrences.isNotEmpty) ...[
                _sectionHeader(
                  title: overdueText,
                  count: overdueOccurrences.length,
                  isDark: isDark,
                  isAlert: true,
                ),
                ...overdueOccurrences.map(
                      (occurrence) => _dismissibleOverdueCard(occurrence),
                ),
                const SizedBox(height: 10),
              ],

              if (todayOccurrences.isNotEmpty) ...[
                _sectionHeader(
                  title: todayText,
                  count: todayOccurrences.length,
                  isDark: isDark,
                ),
                ...todayOccurrences.map(
                      (occurrence) => Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 10,
                    ),
                    child: _taskCard(occurrence),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              if (upcomingOccurrences.isNotEmpty) ...[
                _sectionHeader(
                  title: upcomingText,
                  count: upcomingOccurrences.length,
                  isDark: isDark,
                ),
                ...upcomingOccurrences.map(
                      (occurrence) => Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 10,
                    ),
                    child: _taskCard(occurrence),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              if (pastCompletedOccurrences.isNotEmpty && selectedTab == 0) ...[
                _sectionHeader(
                  title: pastCompletedText,
                  count: pastCompletedOccurrences.length,
                  isDark: isDark,
                ),
                ...pastCompletedOccurrences.map(
                      (occurrence) => Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 10,
                    ),
                    child: _taskCard(occurrence),
                  ),
                ),
              ],

              if (hasMoreTasks)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _visibleTasksCount += _pageSize;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.primary,
                        side: BorderSide(
                          color: AppColor.primary.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.expand_more_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.showMoreTasks,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (displayedOccurrences.isEmpty)
                EmptyState(
                  icon: selectedTab == 1
                      ? Icons.check_circle_outline
                      : Icons.task_alt,
                  title: selectedTab == 1
                      ? l10n.noCompletedTasks
                      : l10n.noTasksYet,
                  message: selectedTab == 1
                      ? l10n.noCompletedTasksMessage
                      : l10n.noTasksYetMessage,
                  buttonText: selectedTab == 0 ? l10n.createTask : null,
                  onPressed: selectedTab == 0
                      ? () async {
                    final provider = context.read<TaskProvider>();
                    final result = await context.push('/Reminder');

                    if (!mounted) return;

                    if (result == true) {
                      await provider.loadTasks();
                    }
                  }
                      : null,
                ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }

  Widget _dismissibleOverdueCard(_TaskOccurrence occurrence) {
    final key = _getOccurrenceKey(occurrence.task, occurrence.date);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final deleteTitle = isAr ? 'حذف المهمة' : 'Delete Task';
    final deleteMsg = isAr
        ? 'هل أنت متأكد من رغبتك في إزالة "${occurrence.task.title}" من المهام المتأخرة؟'
        : 'Are you sure you want to remove "${occurrence.task.title}" from overdue tasks?';
    final cancelText = isAr ? 'إلغاء' : 'Cancel';
    final removeText = isAr ? 'إزالة' : 'Remove';
    final undoText = isAr ? 'تراجع' : 'Undo';
    final movedToTodayText = isAr ? 'نقل لليوم' : 'Move to Today';

    return Dismissible(
      key: Key(key),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final today = _dateOnly(DateTime.now());
          await _rescheduleTaskToDateTime(occurrence, today);
          return true;
        }

        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(deleteTitle),
            content: Text(deleteMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.error,
                ),
                child: Text(removeText),
              ),
            ],
          ),
        ) ??
            false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) return;

        setState(() {
          _dismissedOccurrenceKeys.add(key);
        });

        bool isUndone = false;
        final messenger = ScaffoldMessenger.of(context);

        messenger.removeCurrentSnackBar();
        messenger
            .showSnackBar(
          SnackBar(
            content: Text(
              isAr
                  ? 'تم حذف "${occurrence.task.title}"'
                  : '${occurrence.task.title} removed',
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: undoText,
              textColor: AppColor.primary,
              onPressed: () {
                isUndone = true;
                if (mounted) {
                  setState(() {
                    _dismissedOccurrenceKeys.remove(key);
                  });
                }
              },
            ),
          ),
        )
            .closed
            .then((reason) async {
          if (!isUndone && occurrence.task.repeat == 'none' && mounted) {
            final provider = context.read<TaskProvider>();
            await provider.deleteTask(occurrence.task.id);
          }
        });
      },
      background: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.today_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              movedToTodayText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
        decoration: BoxDecoration(
          color: AppColor.error,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
        child: _taskCard(
          occurrence,
          isOverdue: true,
          onRescheduleToday: () {
            final today = _dateOnly(DateTime.now());
            _rescheduleTaskToDateTime(occurrence, today);
          },
          onPickCustomDateTime: () =>
              _pickCustomRescheduleDateAndTime(occurrence),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required int count,
    required bool isDark,
    bool isAlert = false,
  }) {
    final badgeColor = isAlert ? AppColor.error : AppColor.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isAlert
                  ? AppColor.error
                  : (isDark ? AppColor.textWhite : AppColor.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTask(_TaskOccurrence occurrence) async {
    final provider = context.read<TaskProvider>();

    await provider.toggleTask(
      occurrence.task,
      languageCode: Localizations.localeOf(context).languageCode,
      targetDate: occurrence.date,
    );

    if (!mounted) return;

    if (provider.error != null) {
      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? l10n.errorUpdatingTask)),
      );
    }
  }

  Widget _taskCard(
      _TaskOccurrence occurrence, {
        bool isOverdue = false,
        VoidCallback? onRescheduleToday,
        VoidCallback? onPickCustomDateTime,
      }) {
    final task = occurrence.task;
    final occurrenceDate = occurrence.date;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<TaskProvider>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final isCompleted = provider.isTaskCompletedOnDate(task, occurrenceDate);

    final time =
        '${task.scheduledAt.hour.toString().padLeft(2, '0')}:'
        '${task.scheduledAt.minute.toString().padLeft(2, '0')}';

    final date =
        '${occurrenceDate.day.toString().padLeft(2, '0')}/'
        '${occurrenceDate.month.toString().padLeft(2, '0')}/'
        '${occurrenceDate.year}';

    final textColor = isDark ? AppColor.textWhite : AppColor.textPrimary;
    final secondaryColor = isDark ? AppColor.textHint : AppColor.textSecondary;
    final categoryColor = _getCategoryColor(task.category);
    final priorityColor = _getPriorityColor(task.priority);

    final localizedCategory = _getLocalizedCategory(context, task.category);
    final localizedPriority = _getLocalizedPriority(context, task.priority);

    final moveTodayText = isAr ? 'اليوم' : 'Move to Today';
    final pickDateText = isAr ? 'تاريخ ووقت' : 'Pick Date & Time';

    return GestureDetector(
      onTap: () => _toggleTask(occurrence),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColor.darkSurface : AppColor.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted
                ? AppColor.success.withValues(alpha: 0.35)
                : isOverdue
                ? AppColor.error.withValues(alpha: 0.45)
                : isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColor.border.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggleTask(occurrence),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 23,
                height: 23,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: isCompleted ? AppColor.success : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? AppColor.success
                        : isOverdue
                        ? AppColor.error
                        : isDark
                        ? AppColor.disabled
                        : AppColor.border,
                    width: 1.5,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                  Icons.check_rounded,
                  color: AppColor.textWhite,
                  size: 15,
                )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: isCompleted ? secondaryColor : textColor,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: secondaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          context.go('/ReminderDetails', extra: task);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColor.darkCard
                                : AppColor.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isAr
                                ? Icons.arrow_back_ios_new_rounded
                                : Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _taskInfoItem(
                              icon: Icons.calendar_today_rounded,
                              value: date,
                              color: isOverdue ? AppColor.error : secondaryColor,
                            ),
                            _taskInfoItem(
                              icon: Icons.access_time_rounded,
                              value: time,
                              color: secondaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // شارات الأولوية والتصنيف المترجمة
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: isAr ? WrapAlignment.start : WrapAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: priorityColor.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  size: 11,
                                  color: priorityColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  localizedPriority,
                                  style: TextStyle(
                                    color: priorityColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: categoryColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Text(
                              localizedCategory,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isOverdue && !isCompleted && onRescheduleToday != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        GestureDetector(
                          onTap: onRescheduleToday,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColor.primary.withValues(alpha: 0.20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.today_rounded,
                                  size: 14,
                                  color: AppColor.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  moveTodayText,
                                  style: const TextStyle(
                                    color: AppColor.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (onPickCustomDateTime != null)
                          GestureDetector(
                            onTap: onPickCustomDateTime,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : AppColor.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? AppColor.disabled
                                      : AppColor.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_calendar_rounded,
                                    size: 14,
                                    color: secondaryColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    pickDateText,
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (isCompleted) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColor.success,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          AppLocalizations.of(context)!.completed,
                          style: const TextStyle(
                            color: AppColor.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskInfoItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  static Widget _container({
    required BuildContext context,
    required String value,
    required String title,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isDark ? AppColor.darkCard : AppColor.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
              blurRadius: 6,
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
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColor.textHint : AppColor.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: isDark ? AppColor.textWhite : AppColor.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskOccurrence {
  final TaskModel task;
  final DateTime date;
  final bool isCompleted;

  const _TaskOccurrence({
    required this.task,
    required this.date,
    required this.isCompleted,
  });
}