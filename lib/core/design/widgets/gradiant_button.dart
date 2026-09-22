import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class GradiantButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GradiantButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColor.grad1, AppColor.grad2, AppColor.grad3],
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.transparent,
          foregroundColor: AppColor.textWhite,
          shadowColor: AppColor.transparent,
          surfaceTintColor: AppColor.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: child,
      ),
    );
  }
}
