import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'home/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://530bab498f9b1ae1b6531978c971591c@o4506161856643072.ingest.sentry.io/4506774556114944';
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
