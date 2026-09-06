import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:untitled/core/design/theme/gradiant_colored_container.dart';
import 'package:untitled/l10n/app_localizations.dart';

import '../../../core/design/theme/app_color.dart';
import '../../../core/design/widgets/onboarding_item.dart';
import '../../../model/on_boarding_model.dart';
import '../core/design/widgets/gradiant_button.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final PageController _pageController;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (currentIndex == onboardingData.length - 1) {
      context.go('/Login');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    context.go('/Login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Onboarding is shown before the user chooses Dark/Light mode,
      // so it always uses the Light colors.
      backgroundColor: AppColor.background,

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    AppLocalizations.of(context)!.skip,
                    style: const TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingItem(
                    model: onboardingData[index],
                    index: index,
                  );
                },
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              decoration: const BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: onboardingData.length,
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      activeDotColor: AppColor.primary,
                      dotColor: AppColor.border,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: GradiantButton(
                      onPressed: _nextPage,
                      child: Text(
                        currentIndex == onboardingData.length - 1
                            ? AppLocalizations.of(context)!.start
                            : AppLocalizations.of(context)!.next,
                      ),
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