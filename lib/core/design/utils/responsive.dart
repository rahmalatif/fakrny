import 'package:flutter/material.dart';

class Responsive {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tablet;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktop;
  }

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= desktop) {
      return 1200;
    }

    if (width >= tablet) {
      return 900;
    }

    return width;
  }

  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 1200) {
      return 4;
    }

    if (width >= 900) {
      return 3;
    }

    if (width >= 600) {
      return 2;
    }

    return 1;
  }
}