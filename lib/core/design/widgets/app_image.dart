import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppImage extends StatelessWidget {
  final String image;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (image.endsWith(".svg")) {
      return SvgPicture.asset(
        image,
        width: width,
        height: height,
        fit: fit,
      );
    }

    if (image.endsWith(".png") ||
        image.endsWith(".jpg") ||
        image.endsWith(".jpeg")) {
      return Image.asset(
        image,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return _errorWidget();
  }
}
Widget _errorWidget() {
  return Container(
    color: Colors.grey[200],
    alignment: Alignment.center,
    padding: const EdgeInsets.all(8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.broken_image, size: 48),
        const SizedBox(height: 8),
        const Text(
          'Image load error',
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
        const SizedBox(height: 4),
      ],
    ),
  );
}
