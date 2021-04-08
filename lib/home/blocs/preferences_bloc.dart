import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EventStatus { GET_PREFERENCES }

class GetHomePreferencesEvent {
  final String value;
  final EventStatus status;

  const GetHomePreferencesEvent({this.value, this.status});
}

class HomePreferencesState extends Equatable {
  final String languageCode;
  final bool doSkip;
  
  HomePreferencesState({this.languageCode, this.doSkip});

  @override
  List<Object> get props => [];
}

class GetHomePreferencesBloc extends Bloc<GetHomePreferencesEvent, HomePreferencesState> {
  SharedPreferences _prefs;

  GetHomePreferencesBloc() : super(HomePreferencesState());

  @override
  Stream<HomePreferencesState> mapEventToState(event) async* {
    if (event.status == EventStatus.GET_PREFERENCES) {
      final result = await _getPreferences(event.value);
      yield result;
    }
  }
  
  Future<HomePreferencesState> _getPreferences(String contextLanguageCode) async {
    // check if we should skip the member list
    bool doSkip = false;
    _prefs = await SharedPreferences.getInstance();

    if (_prefs.containsKey('skip_member_list')) {
      bool skip = _prefs.getBool('skip_member_list');

      if (skip) {
        int memberPk = _prefs.getInt('prefered_member_pk');

        if (memberPk != null) {
          await _prefs.setInt('member_pk', memberPk);
          doSkip = true;
        }
      }
    }

    // check the default language
    if (!_prefs.containsKey('prefered_language_code')) {
      await _prefs.setString('prefered_language_code', contextLanguageCode);
    }

    String languageCode = _prefs.getString('prefered_language_code');

    return HomePreferencesState(languageCode: languageCode, doSkip: doSkip);
  }
}
