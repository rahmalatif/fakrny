import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../../model/on_boarding_model.dart';
import '../../logic/context_extension.dart';
import '../theme/app_color.dart';
import 'app_image.dart';

class OnboardingItem extends StatelessWidget {
  final OnboardingModel model;
  final int index;

  const OnboardingItem({
    super.key,
    required this.model,
    required this.index,
  });

  String title(BuildContext context) {
    switch (index) {
      case 0:
        return context.l10n.onboarding1Title;
      case 1:
        return context.l10n.onboarding2Title;
      case 2:
        return context.l10n.onboarding3Title;
      default:
        return "";
    }
  }

  String description(BuildContext context) {
    switch (index) {
      case 0:
        return context.l10n.onboarding1Desc;
      case 1:
        return context.l10n.onboarding2Desc;
      case 2:
        return context.l10n.onboarding3Desc;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: FadeInDown(
              duration: const Duration(milliseconds: 700),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 260,
                    height: 260,
                    decoration: const BoxDecoration(
                      color: AppColor.surface,
                      shape: BoxShape.circle,
                    ),
                  ),

                  AppImage(
                    image: model.image,
                    width: 260,
                    height: 260,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 35,
                ),
                decoration: const BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      title(context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      description(context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColor.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}