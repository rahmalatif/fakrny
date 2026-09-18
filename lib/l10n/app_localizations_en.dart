// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Fakkarny';

  @override
  String get onboarding1Title => 'Simple Reminders, Made Easy';

  @override
  String get onboarding1Desc =>
      'Create reminders in just a few taps and keep track of everything that matters.';

  @override
  String get onboarding2Title => 'Never Miss a Reminder';

  @override
  String get onboarding2Desc =>
      'Get notified before your important tasks and appointments.';

  @override
  String get onboarding3Title => 'Stay Organized Every Day';

  @override
  String get onboarding3Desc =>
      'Organize your tasks, manage your time, and stay on top of your day.';

  @override
  String get skip => 'Skip';

  @override
  String get loginButton => 'Login';

  @override
  String get welcome => 'Welcome Back';

  @override
  String get welcomeSub => 'Sign in to view and manage your reminders';

  @override
  String get email => 'Email';

  @override
  String get continueWith => 'OR Continue With';

  @override
  String get forget => 'Forgot Password?';

  @override
  String get password => 'Password';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get goodNight => 'Good Night';

  @override
  String get smartSuggestion => 'Smart Suggestion';

  @override
  String get smartSuggestionText =>
      'Your optimal focus time is between 9 AM and 12 PM, and you have a meeting at 2 PM. I recommend getting your tasks done now.';

  @override
  String get showMore => 'Show more';

  @override
  String get calender => 'Calender';

  @override
  String get calenderlang => 'en';

  @override
  String get today => 'Today';

  @override
  String get showAll => 'Show All';

  @override
  String get todaysSchadule => 'Today\'s schedule';

  @override
  String get profile => 'Profile';

  @override
  String get userName => 'Rahma Ahmed';

  @override
  String get streak => 'Streak';

  @override
  String get task => 'Tasks';

  @override
  String get progress => 'Progress';

  @override
  String get settings => 'Settings';

  @override
  String get notification => 'Notifications';

  @override
  String get lang => 'Language';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get logout => 'Logout';

  @override
  String get createReminder => 'Create Reminder';

  @override
  String get createReminderSub => 'Add your reminder details';

  @override
  String get title => 'Title';

  @override
  String get titleHint => 'example:study Biology';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get chooseDate => 'Choose Date';

  @override
  String get chooseTime => 'Choose Time';

  @override
  String get category => 'Category';

  @override
  String get chooseCategory => 'Choose Category';

  @override
  String get study => 'Study';

  @override
  String get work => 'Work';

  @override
  String get health => 'Health';

  @override
  String get other => 'Other';

  @override
  String get priority => 'Priority';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get reminderBefore => 'Reminder Before';

  @override
  String get minutes => 'min';

  @override
  String get saveReminder => 'Save Reminder';

  @override
  String get next => 'Next';

  @override
  String get start => 'Start Now';

  @override
  String get reminderDetails => 'Reminder Details';

  @override
  String get repeat => 'Repeat';

  @override
  String get markCompleted => 'Mark as Completed';

  @override
  String get completed => 'Completed';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteReminder => 'Delete Reminder?';

  @override
  String get deleteReminderConfirmation =>
      'Are you sure you want to delete this reminder?';

  @override
  String get cancel => 'Cancel';

  @override
  String get tasks => 'Tasks';

  @override
  String get all => 'All';

  @override
  String get done => 'Done';

  @override
  String get totalTasks => 'Total Tasks';

  @override
  String get completedTasks => 'Completed';

  @override
  String get pendingTasks => 'Pending';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountSub => 'Create your account and get started';

  @override
  String get fullName => 'Full Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get forgetPassword => 'Forgot Password?';

  @override
  String get forgetPasswordSub =>
      'Enter your email and we will send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get noCompletedTasks => 'No completed tasks';

  @override
  String get noTasks => 'No tasks';

  @override
  String get errorUpdatingTask => 'An error occurred while updating the task';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get upcomingTasks => 'Upcoming Tasks';

  @override
  String get appSlogan => 'Forget it... We\'ll remember it for you.';

  @override
  String todayTasksNum(Object count) {
    return 'You have $count tasks today';
  }
}
