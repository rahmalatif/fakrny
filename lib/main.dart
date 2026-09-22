import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/design/theme/lang_controller.dart';
import 'package:untitled/core/design/theme/theme_controller.dart';
import 'package:untitled/core/logic/go_route.dart';
import 'package:untitled/provider/task_provider.dart';
import 'package:untitled/services/auth_services.dart';
import 'package:untitled/services/notification_services.dart';
import 'package:untitled/services/task_firestore_service.dart';
import 'package:untitled/services/user_firestore_service.dart';
import 'core/design/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationServices.init();

  await GoogleSignIn.instance.initialize(
    serverClientId:
        '441958759662-5bmcor94ojfnt3ufa5lj12vl96sfunkf.apps.googleusercontent.com',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => LangController()),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            taskFirestoreService: TaskFirestoreService(),
            authServices: AuthServices(), userFirestoreService: UserFirestoreService(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LangController>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      themeMode: themeController.isDark ? ThemeMode.dark : ThemeMode.light,

      locale: localeController.locale,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [Locale('en'), Locale('ar')],

      routerConfig: appRouter,
    );
  }
}
