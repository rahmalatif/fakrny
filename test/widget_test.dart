import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/design/theme/lang_controller.dart';
import 'package:untitled/core/design/theme/theme_controller.dart';
import 'package:untitled/main.dart';

void main() {
  testWidgets('MyApp builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ThemeController(),
          ),
          ChangeNotifierProvider(
            create: (_) => LangController(),
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();

    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}