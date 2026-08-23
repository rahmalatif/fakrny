import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
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
                          ? Colors.grey
                          : const Color(0xFF202020),
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
                              ? Colors.grey.shade400
                              : Colors.grey,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          color: isCompleted
                              ? Colors.grey.shade400
                              : Colors.grey,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        priority,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? Colors.grey.shade400
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
                activeColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}