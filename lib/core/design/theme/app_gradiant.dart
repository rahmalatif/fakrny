import 'package:flutter/material.dart';
import 'app_color.dart';

class AppGradient {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColor.Grad1,
      AppColor.Grad2,
      AppColor.Grad3,
    ],
  );
}