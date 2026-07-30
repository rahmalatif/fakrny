import 'package:flutter/material.dart';
import 'package:untitled/core/design/widgets/star.dart';

class StarBackground extends StatelessWidget {
  const StarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Star(top: 60, left: 40),
        Star(top: 90, left: 180),
        Star(top: 150, left: 320),
        Star(top: 250, left: 80),
        Star(top: 320, left: 270),
        Star(top: 500, left: 50),
        Star(top: 600, left: 330),
        Star(top: 700, left: 80),
        Star(top: 800, left: 320)
      ],
    );
  }
}
