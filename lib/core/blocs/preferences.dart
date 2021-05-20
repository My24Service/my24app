import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final String preferedLanguageCode;

  Preferences(
    this.preferedLanguageCode
  );
}

enum EventStatus { READ, WRITE }

class PreferencesEvent {
  final String value;
  final EventStatus status;

  const PreferencesEvent({this.value, this.status});
}

class PreferencesBloc extends Bloc<PreferencesEvent, String> {
  String _pref = '';
  SharedPreferences _sPrefs;

  @override
  Stream<String> mapEventToState(event) async* {
    if (event.status == EventStatus.READ) {
      final preferenceValue = await _getPreference(event.value);
      yield preferenceValue;
    } else if (event.status == EventStatus.WRITE) {
      // yield state - event.value;
    }
  }

  PreferencesBloc() : super('') {}

  void dispose() {}

  Future<String> _getPreference(String key) async {
    if (_sPrefs == null) {
      _sPrefs = await SharedPreferences.getInstance();
    }

    return _sPrefs.getString(key);
  }
}
