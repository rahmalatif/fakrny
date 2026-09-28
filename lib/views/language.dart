import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/design/theme/app_color.dart';
import '../core/design/theme/lang_controller.dart';
import '../core/design/widgets/gradiant_button.dart';
import '../core/logic/app_routes.dart';
import '../l10n/app_localizations.dart';

class LanguageView extends StatefulWidget {
  const LanguageView({super.key});

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  String? _selectedLanguage;

  Future<void> _selectLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });

    await context.read<LangController>().changeLocale(Locale(languageCode));
  }

  void _continue() {
    if (_selectedLanguage == null) return;

    context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColor.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const Spacer(),

              Text(
                l10n.chooseLanguage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                l10n.chooseLanguageDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColor.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              _LanguageOption(
                title: l10n.english,
                flag: '🇬🇧',
                isSelected: _selectedLanguage == 'en',
                onTap: () => _selectLanguage('en'),
              ),

              const SizedBox(height: 16),

              _LanguageOption(
                title: l10n.arabic,
                flag: '🇪🇬',
                isSelected: _selectedLanguage == 'ar',
                onTap: () => _selectLanguage('ar'),
              ),

              const Spacer(),

              SizedBox(
                height: 56,

                child: GradiantButton(
                  onPressed: _continue,
                  child: Text(l10n.continueButton),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

        decoration: BoxDecoration(
          color: AppColor.surface,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: isSelected ? AppColor.primary : AppColor.border,

            width: isSelected ? 2 : 1,
          ),
        ),

        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
            ),

            if (isSelected)
              const Icon(Icons.check_circle, color: AppColor.primary),
          ],
        ),
      ),
    );
  }
}
