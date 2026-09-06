import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class TasksContanier extends StatelessWidget {
  final String title;
  final String time;
  final String category;
  final String priority;
  final Color color;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onCheck;

  const TasksContanier({
    super.key,
    required this.title,
    required this.time,
    required this.category,
    required this.priority,
    required this.color,
    required this.isCompleted,
    this.onTap,
    this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColor.darkSurface
              : AppColor.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? AppColor.textHint
                          : isDark
                          ? AppColor.textWhite
                          : AppColor.textPrimary,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 14,
                          color: isCompleted
                              ? AppColor.disabled
                              : AppColor.textSecondary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          color: isCompleted
                              ? AppColor.disabled
                              : AppColor.textSecondary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        priority,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? AppColor.disabled
                              : color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            GestureDetector(
              onTap: onCheck,
              child: Checkbox(
                value: isCompleted,
                onChanged: (_) {
                  onCheck?.call();
                },
                activeColor: AppColor.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}