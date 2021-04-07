import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class My24App extends StatefulWidget {
  @override
  _My24AppState createState() => _My24AppState();
}

class _My24AppState extends State<My24App> {
  Locale _locale;
  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _setSharedPrefs();
    await _setLocale();
    await _getLocale();
  }

  _setSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _setLocale() async {
    if(!_prefs.containsKey('prefered_language_code')) {
      await prefs.setString('prefered_language_code', context.locale.languageCode);
    }
  }

  _getLocale() async {
    String languageCode = _prefs.getString('prefered_language_code');

    setState(() {
      _locale = lang2locale(languageCode);
      context.locale = _locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: _locale,
      theme: ThemeData(
          primaryColor: Color.fromARGB(255, 255, 153, 51)
      ),
      title: 'main.title'.tr(),
      home: Scaffold(
          appBar: AppBar(
            title: Text(_doSkip ? _member.name : 'main.app_bar_title'.tr()),
          ),
          body: Container(
              child: Column(
                children: [
                  _showLandingPage(context)
                ],
              )
          )
      ),
    );
  }
}
