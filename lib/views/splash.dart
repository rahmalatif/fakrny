import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/core/design/widgets/star_background.dart';
import '../core/design/theme/gradiant_colored_container.dart';
import '../core/design/widgets/animated_logo.dart';
import '../l10n/app_localizations.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  void _navigateTo() {
    context.go('/onBoarding');
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      context.go('/onBoarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateTo,
      child: Scaffold(
        body: GradiantColors(
          child: Stack(
            children: [
              const StarBackground(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AnimatedLogo(),

                    const SizedBox(height: 30),

                    FadeInUp(
                      delay: const Duration(milliseconds: 700),
                      child: Text(
                        AppLocalizations.of(context)!.appName,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    FadeIn(
                      delay: const Duration(milliseconds: 1200),
                      child: Container(
                        width: 60,
                        height: 2,
                        color: Colors.white30,
                      ),
                    ),

                    const SizedBox(height: 30),

                    FadeInUp(
                      delay: const Duration(milliseconds: 1300),
                      child:  Text(
                        AppLocalizations.of(context)!.appSlogan,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
