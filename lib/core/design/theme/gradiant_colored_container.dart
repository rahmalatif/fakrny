import 'package:flutter/material.dart';

import 'app_color.dart';

class GradiantColors extends StatelessWidget {
  final Widget child;
  const GradiantColors({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
           AppColor.grad1,
           AppColor.grad2,
           AppColor.grad3,

            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
