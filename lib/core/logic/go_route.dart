import 'package:go_router/go_router.dart';
import 'package:untitled/views/calender.dart';
import 'package:untitled/views/forget_password.dart';
import 'package:untitled/views/home.dart';
import 'package:untitled/views/login.dart';
import 'package:untitled/views/profile.dart';
import 'package:untitled/views/register.dart';
import 'package:untitled/views/reminder.dart';
import 'package:untitled/views/splash.dart';
import 'package:untitled/views/tasks.dart';
import '../../views/on_boarding.dart';
import '../../views/reminder_details.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: AppRoutes.calender,
      builder: (context, state) => const CalenderView(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileView(),
    ),
    GoRoute(
      path: AppRoutes.reminder,
      builder: (context, state) => const ReminderView(),
    ),
    GoRoute(
      path: AppRoutes.reminderDetails,
      builder: (context, state) => const ReminderDetailsView(),
    ),
    GoRoute(
      path: AppRoutes.tasks,
      builder: (context, state) => const TasksView(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: AppRoutes.forgetPass,
      builder: (context, state) => const ForgetPasswordView(),
    ),
  ],
);
