import 'package:flutter/material.dart';
import 'package:untitled/l10n/app_localizations.dart';

class ReminderView extends StatelessWidget {
  const ReminderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppLocalizations.of(context)!.createReminder, style: TextStyle(
            fontWeight: FontWeight.bold,
          ),),
        ),
      ),
    );
  }
}
