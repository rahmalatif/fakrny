import 'package:flutter/material.dart';

class OnboardingModel {
  final String image;
  final String title;
  final String description;
  final Color buttonColor;

  const OnboardingModel({
    required this.image,
    required this.title,
    required this.description,
    required this.buttonColor,
  });
}