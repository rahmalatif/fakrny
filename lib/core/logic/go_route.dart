import 'package:firebase_auth/firebase_auth.dart';
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
import '../../model/tasks.dart';
import '../../views/language.dart';
import '../../views/on_boarding.dart';
import '../../views/reminder_details.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    final isLoggedIn = user != null;

    final isSplash = state.matchedLocation == AppRoutes.splash;
    final isLanguage = state.matchedLocation == AppRoutes.language;
    final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
    final isLogin = state.matchedLocation == AppRoutes.login;
    final isRegister = state.matchedLocation == AppRoutes.register;
    final isForgetPass = state.matchedLocation == AppRoutes.forgetPass;

    final isPublicRoute =
        isSplash ||
        isLanguage ||
        isOnboarding ||
        isLogin ||
        isRegister ||
        isForgetPass;

    if (!isLoggedIn && !isPublicRoute) {
      return AppRoutes.login;
    }

    if (isLoggedIn && isLogin) {
      return AppRoutes.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppRoutes.language,
      builder: (context, state) => const LanguageView(),
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
      builder: (context, state) {
        final task = state.extra as TaskModel?;

        return ReminderView(task: task);
      },
    ),
    GoRoute(
      path: AppRoutes.reminderDetails,
      builder: (context, state) {
        final task = state.extra as TaskModel;

        return ReminderDetailsView(task: task);
      },
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
