import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/core/design/theme/app_color.dart';
import 'package:untitled/core/design/widgets/app_image.dart';
import 'package:untitled/core/design/widgets/gradiant_button.dart';

import '../core/design/widgets/form.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_services.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  final AuthServices authServices = AuthServices();
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    final l10n = AppLocalizations.of(context)!;

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseFillAllFields)));
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.passwordsDoNotMatch)));
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await authServices.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountCreatedSuccessfully)));

      context.go('/Login');
    } on FirebaseAuthException catch (e) {
      String message = l10n.somethingWentWrong;

      if (e.code == 'email-already-in-use') {
        message = l10n.emailAlreadyRegistered;
      } else if (e.code == 'invalid-email') {
        message = l10n.invalidEmail;
      } else if (e.code == 'weak-password') {
        message = l10n.weakPassword;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> registerWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      setState(() {
        isLoading = true;
      });

      final userCredential = await authServices.signInWithGoogle();

      if (!mounted) return;

      if (userCredential != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accountCreatedSuccessfully)),
        );

        await authServices.logout();

        if (!mounted) return;

        context.go('/Login');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.background,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * .68,
                ),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(blurRadius: 20, color: Colors.black12),
                  ],
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.createAccount,
                        style: const TextStyle(
                          fontSize: 28,
                          color: AppColor.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        l10n.createAccountSub,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColor.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: nameController,
                        keyboardType: TextInputType.name,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppColor.textSecondary,
                        ),
                        title: l10n.fullName,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColor.textSecondary,
                        ),
                        title: l10n.email,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColor.textSecondary,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColor.textSecondary,
                          ),
                        ),
                        title: l10n.password,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: confirmPasswordController,
                        obscureText: !isConfirmPasswordVisible,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColor.textSecondary,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                          icon: Icon(
                            isConfirmPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColor.textSecondary,
                          ),
                        ),
                        title: l10n.confirmPassword,
                      ),
                      const SizedBox(height: 24),
                      GradiantButton(
                        onPressed: () {
                          if (!isLoading) {
                            registerUser();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColor.textWhite,
                                  ),
                                )
                              : Text(
                                  l10n.createAccount,
                                  style: const TextStyle(
                                    color: AppColor.textWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColor.border,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              l10n.continueWith,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColor.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColor.border,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: isLoading ? null : registerWithGoogle,
                              child: _socialButton(
                                icon: 'assets/SVG/google_icon.svg',
                                text: l10n.google,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.alreadyHaveAccount,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColor.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                context.go('/Login');
                              },
                              child: Text(
                                l10n.loginButton,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _socialButton({required String icon, required String text}) {
  return Container(
    width: 145,
    height: 55,
    decoration: BoxDecoration(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: AppColor.border),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(image: icon, width: 24, height: 24),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}
