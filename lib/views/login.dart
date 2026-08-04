import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/core/design/theme/app_gradiant.dart';
import 'package:untitled/core/design/widgets/app_image.dart';
import 'package:untitled/core/design/widgets/gradiant_button.dart';

import '../core/design/widgets/form.dart';
import '../core/design/widgets/star.dart';
import '../l10n/app_localizations.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

final emailController = TextEditingController();
final passwordController = TextEditingController();


class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF5F5F5),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .4,
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
                      backgroundColor: Colors.transparent,
                      child: Padding(
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
                height: MediaQuery.of(context).size.height * .68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcome,
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        AppLocalizations.of(context)!.welcomeSub,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),

                      SizedBox(height: 24),
                      AppTextField(
                        hintText: AppLocalizations.of(context)!.email,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        hintText: AppLocalizations.of(context)!.password,
                        controller: passwordController,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: const Icon(Icons.visibility_off_outlined),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              AppLocalizations.of(context)!.forget,
                              style: TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      GradiantButton(
                        onPressed: () {
                          context.go('/Home');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context)!.loginButton,

                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade400,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              AppLocalizations.of(context)!.continueWith,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade400,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _socialButton(
                              icon: 'assets/SVG/google_icon.svg',
                              text: 'Google',
                            ),
                            _socialButton(
                              icon: 'assets/SVG/apple_icon.svg',
                              text: 'Apple',
                            ),
                          ],
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

Widget _socialButton({required String icon, required String text}) {
  return Container(
    width: 145,
    height: 55,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: Colors.grey.shade200),
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
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
