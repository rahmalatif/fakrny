import 'package:flutter/material.dart';
import 'package:untitled/core/design/widgets/app_image.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Container(
            width: 200 + (_scaleAnimation.value * 10),
            height: 200 + (_scaleAnimation.value * 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.08),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(.10),
                  blurRadius: 35,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.18),
              border: Border.all(
                color: Colors.white24,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(.25),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: AppImage(
                image: 'assets/JPG_Images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}