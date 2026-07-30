import 'package:flutter/material.dart';

class Star extends StatelessWidget {
  final double top;
  final double left;

  const Star({super.key, required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: top,
        left: left,
        child:Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.yellowAccent,
            shape: BoxShape.circle
          ),
        ));
  }
}
