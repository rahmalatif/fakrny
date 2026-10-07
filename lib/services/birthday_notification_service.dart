import 'package:untitled/services/notification_services.dart';

class BirthdayNotificationService {
  static Future<void> scheduleBirthdayNotifications({
    required int month,
    required int day,
    required String language,
    required String voiceGender,
  }) async {
    await NotificationServices.scheduleBirthdayNotifications(
      month: month,
      day: day,
      languageCode: language,
      voiceGender: voiceGender,
    );
  }

  static Future<void> cancelBirthdayNotifications() async {
    await NotificationServices.cancelBirthdayNotifications();
  }
}