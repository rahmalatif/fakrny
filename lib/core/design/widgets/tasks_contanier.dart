import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class TasksContanier extends StatelessWidget {
  final String title;
  final String category;
  final String priority;
  final String time;
  final Color color;
  final Color categoryColor;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onCheck;

  const TasksContanier({
    super.key,
    required this.title,
    required this.category,
    required this.priority,
    required this.time,
    required this.color,
    required this.categoryColor,
    required this.isCompleted,
    this.onTap,
    this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? AppColor.textWhite : AppColor.textPrimary;

    final secondaryColor = isDark ? AppColor.textHint : AppColor.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColor.darkSurface : AppColor.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColor.success.withValues(alpha: 0.25)
                : isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColor.border.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Category Dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: categoryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.25),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Task Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Task Title
                  Text(
                    title,
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

                  const SizedBox(height: 9),

                  // Category and Priority
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isCompleted ? secondaryColor : categoryColor,
                        ),
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: secondaryColor.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        priority,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? secondaryColor : color,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  // Task Time
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: secondaryColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Completion Checkbox
            SizedBox(
              width: 36,
              height: 40,
              child: Center(
                child: Checkbox(
                  value: isCompleted,
                  onChanged: (_) => onCheck?.call(),
                  activeColor: AppColor.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
