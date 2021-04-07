import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final String preferedLanguageCode;

  Preferences(
    this.preferedLanguageCode
  );
}

class PreferencesBloc extends BlocBase<String> {
  String _pref = '';
  SharedPreferences sPrefs;

  //
  // Stream to handle the counter
  // ignore: close_sinks
  StreamController<String> _counterController = StreamController<String>();
  StreamSink<String> get _inAdd => _counterController.sink;
  Stream<String> get get => _counterController.stream;

  //
  // Stream to handle the action on the counter
  //
  // ignore: close_sinks
  StreamController _actionController = StreamController();
  StreamSink get incrementCounter => _actionController.sink;

  PreferencesBloc() : super('') {
    _actionController.stream.listen(_handleLogic);
    _loadSharedPreferences();
  }

  void dispose(){
    _actionController.close();
    _counterController.close();
  }

  void _handleLogic(data) {
    print('data: $data');
    _pref = 'HAI';
    _inAdd.add(_pref);
  }

  Future<void> _loadSharedPreferences() async {
    sPrefs = await SharedPreferences.getInstance();
    final String preferedLanguageCode = sPrefs.getString("preferedLanguageCode") ?? "";
  }
}
