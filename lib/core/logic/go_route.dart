import 'package:go_router/go_router.dart';
import 'package:untitled/views/calender.dart';
import 'package:untitled/views/home.dart';
import 'package:untitled/views/login.dart';
import 'package:untitled/views/splash.dart';
import '../../views/on_boarding.dart';
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
  ],
);
