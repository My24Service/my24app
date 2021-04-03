import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:easy_localization/src/localization.dart';

import 'package:my24app/main.dart';

// class TranslationsMock extends Mock implements Translations {}


Widget createLocalizedWidgetForTesting({Widget child}) {
  return EasyLocalization(
    supportedLocales: [
      Locale('en', 'US'),
      Locale('nl', 'NL'),
      // Locale('de', 'DE'),
    ],
    path: 'resources/langs',
    fallbackLocale: Locale('en', 'US'),
    child: child
  );
}

Future setupPreferences(String key, String value) async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, dynamic>{'flutter.' + key: value});
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(key, value);
}


main() async {
  await EasyLocalization.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  File('resources/langs/en-US.json').readAsString().then((String contents) {
    Map<String, dynamic> data = jsonDecode(contents);
    Localization.load(Locale('en', 'US'), translations: Translations(data));
  });

  File('resources/langs/nl-NL.json').readAsString().then((String contents) {
    Map<String, dynamic> data = jsonDecode(contents);
    Localization.load(Locale('nl', 'NL'), translations: Translations(data));
  });

  testWidgets('main renders en-US', (WidgetTester tester) async {
    await setupPreferences('prefered_language_code', 'en');

    await tester.pumpWidget(
      createLocalizedWidgetForTesting(
        child: My24App()
      )
    );
  });

  testWidgets('main renders nl-NL', (WidgetTester tester) async {
    await setupPreferences('prefered_language_code', 'en');
    await tester.pumpWidget(
      createLocalizedWidgetForTesting(
        child: My24App()
      )
    );
  });

}
