import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/core/design/theme/app_color.dart';
import 'package:untitled/core/design/theme/app_gradiant.dart';
import 'package:untitled/core/design/widgets/app_image.dart';
import 'package:untitled/core/design/widgets/gradiant_button.dart';

import '../core/design/widgets/form.dart';
import '../core/design/widgets/star.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_services.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final TextEditingController emailController = TextEditingController();
  final AuthServices authServices = AuthServices();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendResetPasswordEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your email')));
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await authServices.resetPassword(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link has been sent to your email'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';

      if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      } else if (e.code == 'user-not-found') {
        message = 'No account found with this email';
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.background,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Container(
              height: screenHeight * .3,
              width: double.infinity,
              decoration: const BoxDecoration(gradient: AppGradient.primary),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Star(top: 25, left: 35),
                  Star(top: 45, left: 170),
                  Star(top: 95, left: 15),
                  Star(top: 110, left: 25),
                  Star(top: 80, left: 85),
                  Star(top: 170, left: 50),
                  Star(top: 25, left: 235),
                  Star(top: 45, left: 370),
                  Star(top: 95, left: 215),
                  Star(top: 110, left: 225),
                  Star(top: 80, left: 285),
                  Star(top: 170, left: 250),
                  Star(top: 270, left: 250),
                  Center(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: AppColor.transparent,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: AppImage(image: 'assets/JPG_Images/logo.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: screenHeight * .68),
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
                        AppLocalizations.of(context)!.forgetPassword,
                        style: const TextStyle(
                          fontSize: 28,
                          color: AppColor.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppLocalizations.of(context)!.forgetPasswordSub,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColor.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      AppTextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColor.textSecondary,
                        ),
                        title: AppLocalizations.of(context)!.email,
                      ),
                      const SizedBox(height: 28),
                      GradiantButton(
                        onPressed: () {
                          if (!isLoading) {
                            sendResetPasswordEmail();
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
                                  AppLocalizations.of(context)!.sendResetLink,
                                  style: const TextStyle(
                                    color: AppColor.textWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            context.go('/Login');
                          },
                          child: Text(
                            AppLocalizations.of(context)!.backToLogin,
                            style: const TextStyle(
                              color: AppColor.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
