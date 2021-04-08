import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'home/blocs/preferences_bloc.dart';
import 'home/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: [
          Locale('en', 'US'),
          Locale('nl', 'NL'),
          // Locale('de', 'DE'),
        ],
        path: 'resources/langs',
        fallbackLocale: Locale('en', 'US'),
        child: BlocProvider(
          create: (BuildContext context) => GetHomePreferencesBloc(),
          child: My24App(),
        )
    ),
  );
}
