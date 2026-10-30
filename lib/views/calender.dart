import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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

  Color _getMarkerPriorityColor(List<TaskModel> events, bool isSelected) {
    if (isSelected) return Colors.white;

    // أولوية عالية
    if (events.any((t) => t.priority.toLowerCase() == 'high')) {
      return AppColor.error;
    }
    // أولوية متوسطة
    if (events.any((t) => t.priority.toLowerCase() == 'medium')) {
      return Colors.amber;
    }
    // أولوية منخفضة
    return Colors.green;
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
              const SizedBox(height: 24),
              _buildCalendar(),
              const SizedBox(height: 30),
              _buildSelectedDayTasks(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  Widget _buildTitle(bool isDark) {
    final l10n = AppLocalizations.of(context)!;

    return Text(
      l10n.calender,
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkSurface : AppColor.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TableCalendar<TaskModel>(
        locale: l10n.calenderlang,
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: _focusedDay,
        currentDay: DateTime.now(),
        rowHeight: 46,
        daysOfWeekHeight: 28,

        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) => taskProvider.tasksForDate(day),

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
            if (events.isEmpty) return null;

            final isSelected = isSameDay(_selectedDay, day);
            final markerColor = _getMarkerPriorityColor(events, isSelected);

            return Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? null
                      : [
                    BoxShadow(
                      color: markerColor.withValues(alpha: 0.45),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          headerPadding: const EdgeInsets.only(bottom: 12),
          titleTextStyle: TextStyle(
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          leftChevronIcon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: isDark ? AppColor.textWhite : AppColor.textPrimary,
            ),
          ),
          rightChevronIcon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? AppColor.textWhite : AppColor.textPrimary,
            ),
          ),
        ),

        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColor.textHint : AppColor.textSecondary,
          ),
          weekendStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColor.textHint : AppColor.textSecondary,
          ),
        ),

        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
          ),
          weekendTextStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColor.textWhite : AppColor.textPrimary,
          ),
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.primary, width: 1.5),
            color: AppColor.primary.withValues(alpha: 0.08),
          ),
          todayTextStyle: const TextStyle(
            color: AppColor.primary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColor.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          cellMargin: const EdgeInsets.all(3),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (selectedTasks.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${selectedTasks.length}',
                  style: const TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            Text(
              l10n.todaysSchadule,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColor.textWhite : AppColor.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (selectedTasks.isEmpty)
          _buildEmptyTasksState()
        else
          ...selectedTasks.map(
                (task) {
              final isTaskDone = taskProvider.isTaskCompletedOnDate(
                task,
                selectedDay,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskItemCard(
                  task: task,
                  isDark: isDark,
                  isCompleted: isTaskDone,
                  onTap: () {
                    context.push('/ReminderDetails', extra: task);
                  },
                  onToggle: () {
                    taskProvider.toggleTask(
                      task,
                      targetDate: selectedDay,
                      languageCode: Localizations.localeOf(context).languageCode,
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyTasksState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkCard : AppColor.secondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            child: Icon(
              Icons.event_available_outlined,
              size: 32,
              color: isDark ? AppColor.textHint : AppColor.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noTasks,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColor.textHint : AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskItemCard extends StatefulWidget {
  final TaskModel task;
  final bool isDark;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const TaskItemCard({
    super.key,
    required this.task,
    required this.isDark,
    required this.isCompleted,
    required this.onTap,
    required this.onToggle,
  });

  @override
  State<TaskItemCard> createState() => _TaskItemCardState();
}

class _TaskItemCardState extends State<TaskItemCard>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  late AnimationController _confettiController;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _confettiAnimation = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _handleToggle() async {
    final wasCompleted = widget.isCompleted;

    HapticFeedback.lightImpact();

    await _bounceController.forward();
    _bounceController.reverse();

    if (!wasCompleted) {
      _confettiController.forward(from: 0.0);
    }

    widget.onToggle();
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColor.darkCard : AppColor.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isCompleted
                ? Colors.transparent
                : (widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimatedBuilder(
                    animation: _confettiAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(60, 60),
                        painter: ConfettiPainter(
                          progress: _confettiAnimation.value,
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _handleToggle,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isCompleted
                              ? AppColor.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: widget.isCompleted
                                ? AppColor.primary
                                : (widget.isDark
                                ? AppColor.textHint
                                : AppColor.textSecondary
                                .withValues(alpha: 0.4)),
                            width: 2,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: widget.isCompleted
                              ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('completed_icon'),
                            color: Colors.white,
                            size: 18,
                          )
                              : const SizedBox.shrink(
                            key: ValueKey('empty_box'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isCompleted ? 0.6 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.task.title,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration:
                        widget.isCompleted ? TextDecoration.lineThrough : null,
                        color: widget.isCompleted
                            ? (widget.isDark
                            ? AppColor.textHint
                            : AppColor.textSecondary)
                            : (widget.isDark
                            ? AppColor.textWhite
                            : AppColor.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(widget.task.scheduledAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark
                                ? AppColor.textHint
                                : AppColor.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: widget.isDark
                              ? AppColor.textHint
                              : AppColor.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  ConfettiPainter({
    required this.progress,
    this.colors = const [
      Color(0xFF6C63FF),
      Color(0xFFFF6584),
      Color(0xFFFFD166),
      Color(0xFF06D6A0),
      Color(0xFF118AB2),
    ],
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    const count = 12;
    final maxDistance = size.width * 0.85;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (int i = 0; i < count; i++) {
      final angle = (2 * math.pi / count) * i;
      final distance = progress * maxDistance;

      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);

      final color = colors[i % colors.length].withValues(alpha: opacity);
      final paint = Paint()..color = color;

      if (i.isEven) {
        canvas.drawCircle(Offset(x, y), 2.5 * (1.0 - progress * 0.5), paint);
      } else {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(progress * math.pi);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: 4.5 * (1.0 - progress * 0.4),
            height: 4.5 * (1.0 - progress * 0.4),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}