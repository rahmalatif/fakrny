import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:untitled/core/design/widgets/app_image.dart';
import 'package:untitled/core/design/widgets/star_background.dart';

import '../core/design/theme/gradiant_colors.dart';
import '../core/design/widgets/animated_logo.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}


class _SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradiantColors(
        child: Stack(
          children: [
            const StarBackground(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  AnimatedLogo(),
                  const SizedBox(height: 30),

                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: const Text(
                      "فكرني",
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
                    child: const Text(
                      "انسى... واحنا نفكرك",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
