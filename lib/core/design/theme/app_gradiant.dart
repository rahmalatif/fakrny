import 'package:flutter/material.dart';
import 'app_color.dart';

class AppGradient {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColor.grad1,
      AppColor.grad2,
      AppColor.grad3,
    ],
  );
}