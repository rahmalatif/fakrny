import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_color.dart';
import '../theme/app_gradiant.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomNavBar({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go('/Home');
        break;

      case 1:
        context.go('/tasks');
        break;

      case 2:
        context.go('/Calender');
        break;

      case 3:
        context.go('/Profile');
        break;
    }
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return const _AddTaskBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.12),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => _navigate(context, 0),
                ),
              ),

              Expanded(
                child: _NavItem(
                  icon: Icons.task_alt_outlined,
                  selectedIcon: Icons.task_alt_rounded,
                  label: 'Tasks',
                  isSelected: currentIndex == 1,
                  onTap: () => _navigate(context, 1),
                ),
              ),

              _AddButton(onTap: () => _showAddMenu(context)),

              Expanded(
                child: _NavItem(
                  icon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_month_rounded,
                  label: 'Calendar',
                  isSelected: currentIndex == 2,
                  onTap: () => _navigate(context, 2),
                ),
              ),

              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: currentIndex == 3,
                  onTap: () => _navigate(context, 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradient.primary : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: isSelected
              ? Row(
                  key: const ValueKey('selected'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(selectedIcon, size: 21, color: AppColor.textWhite),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColor.textWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                )
              : Icon(
                  icon,
                  key: const ValueKey('unselected'),
                  size: 24,
                  color: AppColor.textSecondary,
                ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradient.primary,
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.35),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AppColor.textWhite,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _AddTaskBottomSheet extends StatelessWidget {
  const _AddTaskBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
      decoration: const BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: AppColor.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Create New',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColor.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'What would you like to create?',
            style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
          ),

          const SizedBox(height: 12),

          _AddOption(
            icon: Icons.notifications,
            title: 'Reminder',
            subtitle: 'What would you like to create?',
            color: AppColor.secondary,
            iconColor: AppColor.primary,
            onTap: () {
              context.go('/Reminder');
            },
          ),

          const SizedBox(height: 12),

          _AddOption(
            icon: Icons.flag_rounded,
            title: 'Task',
            subtitle: 'Something you need to get done',
            color: AppColor.secondary,
            iconColor: AppColor.primary,
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 12),

          /*          _AddOption(
            icon: Icons.notifications_active_rounded,
            title: 'Goal',
            subtitle: 'Something you want to achieve',
            color: AppColor.secondary,
            iconColor: AppColor.primary,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          */
        ],
      ),
    );
  }
}

class _AddOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient? gradient;
  final Color? color;
  final Color? iconColor;
  final VoidCallback onTap;

  const _AddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.gradient,
    this.color,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? color : null,
          borderRadius: BorderRadius.circular(20),
          border: gradient == null ? Border.all(color: AppColor.border) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: gradient != null
                    ? Colors.white.withOpacity(0.18)
                    : AppColor.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: gradient != null ? AppColor.textWhite : iconColor,
                size: 25,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: gradient != null
                          ? AppColor.textWhite
                          : AppColor.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: gradient != null
                          ? AppColor.textWhite.withOpacity(0.8)
                          : AppColor.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: gradient != null
                  ? AppColor.textWhite
                  : AppColor.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
