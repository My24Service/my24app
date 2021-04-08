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
  final int memberPk;

  HomePreferencesState({this.languageCode, this.doSkip, this.memberPk});

  @override
  List<Object> get props => [];
}

class GetHomePreferencesBloc extends Bloc<GetHomePreferencesEvent, HomePreferencesState> {
  SharedPreferences prefs;

  GetHomePreferencesBloc() : super(HomePreferencesState());

  @override
  Stream<HomePreferencesState> mapEventToState(event) async* {
    if (event.status == EventStatus.GET_PREFERENCES) {
      final result = await _getPreferences(event.value);
      yield result;
    }
  }

  Future<HomePreferencesState> _getPreferences(String contextLanguageCode) async {
    prefs = await SharedPreferences.getInstance();
    bool doSkip = false;
    String languageCode;
    int memberPk;

    if (prefs.containsKey('skip_member_list')) {
      bool skip = prefs.getBool('skip_member_list');

      if (skip) {
        int preferedMemberPk = prefs.getInt('prefered_member_pk');

        if (preferedMemberPk != null) {
          memberPk = preferedMemberPk;
          doSkip = true;
        }
      }
    }

    // check the default language
    if (!prefs.containsKey('prefered_language_code')) {
      await prefs.setString('prefered_language_code', contextLanguageCode);
    }

    languageCode = prefs.getString('prefered_language_code');

    return HomePreferencesState(
      languageCode: languageCode,
      doSkip: doSkip,
      memberPk: memberPk);
  }
}
