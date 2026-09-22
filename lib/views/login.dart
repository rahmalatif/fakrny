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

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  final AuthServices authServices = AuthServices();
  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await authServices.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      context.go('/Home');
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';

      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        message = 'Invalid email or password';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
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

  Future<void> signInWithGoogle() async {
    try {
      setState(() {
        isGoogleLoading = true;
      });


      await authServices.signInWithGoogle();

      if (!mounted) return;

      context.go('/Home');
    } on FirebaseAuthException catch (e) {
      debugPrint('🔥 Firebase Auth Error');
      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${e.code}: ${e.message}',
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('🔥 Google Sign In Error: $e');
      debugPrint('StackTrace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.background,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .3,
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
                height: MediaQuery.of(context).size.height * .75,
                width: double.infinity,
                constraints: BoxConstraints(
                //  minHeight: MediaQuery.of(context).size.height * .68,
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
                        AppLocalizations.of(context)!.welcome,
                        style: const TextStyle(
                          fontSize: 28,
                          color: AppColor.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        AppLocalizations.of(context)!.welcomeSub,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColor.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      AppTextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColor.textSecondary,
                        ),
                        title: AppLocalizations.of(context)!.email,
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
                        title: AppLocalizations.of(context)!.password,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                context.go('/ForgetPass');
                              },

                              child: Text(
                                AppLocalizations.of(context)!.forget,
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

                      const SizedBox(height: 20),

                      GradiantButton(
                        onPressed: () {
                          if (!isLoading) {
                            loginUser();
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
                                  AppLocalizations.of(context)!.loginButton,
                                  style: const TextStyle(
                                    color: AppColor.textWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.dontHaveAccount,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColor.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              context.go('/Register');
                            },
                            child: Text(
                              AppLocalizations.of(context)!.register,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColor.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
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
                              AppLocalizations.of(context)!.continueWith,
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
                            _socialButton(
                              icon: 'assets/SVG/google_icon.svg',
                              text: 'Google',
                              onTap: isGoogleLoading ? null : signInWithGoogle,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
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

Widget _socialButton({
  required String icon,
  required String text,
  required VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
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
            AppImage(
              image: icon,
              width: 24,
              height: 24,
            ),
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
    ),
  );
}
