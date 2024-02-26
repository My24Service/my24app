import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'home/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
    },
    // Init your App.
    appRunner: () => runApp(
      EasyLocalization(
          supportedLocales: [
            Locale('en', 'US'),
            Locale('nl', 'NL'),
            // Locale('de', 'DE'),
          ],
          path: 'resources/langs',
          fallbackLocale: Locale('en', 'US'),
          child: My24App()
      ),
    ),
  );
}
