import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class SnackBarHelper {
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
  }) {
    final config = _getConfig(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(config.icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: config.color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static _SnackBarConfig _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(color: Colors.green, icon: Icons.check_circle);

      case SnackBarType.error:
        return _SnackBarConfig(color: Colors.red, icon: Icons.error);

      case SnackBarType.warning:
        return _SnackBarConfig(color: Colors.orange, icon: Icons.warning);

      case SnackBarType.info:
        return _SnackBarConfig(color: Colors.blue, icon: Icons.info);
    }
  }
}

class _SnackBarConfig {
  final Color color;
  final IconData icon;

  _SnackBarConfig({required this.color, required this.icon});
}
