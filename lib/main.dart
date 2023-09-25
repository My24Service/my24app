import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

import 'home/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  FlutterBranchSdk.validateSDKIntegration();

  runApp(
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
  );
}
