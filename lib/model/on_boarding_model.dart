import 'package:flutter/material.dart';

class OnboardingModel {
  final String image;
  final String title;
  final String description;

  const OnboardingModel({
    required this.image,
    required this.title,
    required this.description,
  });
}

const List<OnboardingModel> onboardingData = [
  OnboardingModel(
    image: "assets/JPG_Images/sun.png",
    title: "تذكيرات بلغتك الطبيعية",
    description: "فقط اكتب ما تريد تذكره... وسيقوم الذكاء الاصطناعي بكل شيء.",
  ),

  OnboardingModel(
    image: "assets/JPG_Images/moon2.png",
    title: "إشعارات ذكية في الوقت المناسب",
    description: "يحلل الذكاء الاصطناعي جدولك ويختار أنسب وقت للتذكير.",
  ),

  OnboardingModel(
    image: "assets/JPG_Images/moon.png",
    title: "مساعدك الشخصي بالذكاء الاصطناعي",
    description: "ينظم مهامك وأولوياتك ويساعدك على إنجاز أكثر.",
  ),
];
