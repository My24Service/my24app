import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:my24app/home/blocs/preferences_states.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HomeEventStatus { GET_PREFERENCES }

class GetHomePreferencesEvent {
  final String value;
  final HomeEventStatus status;

  const GetHomePreferencesEvent({this.value, this.status});
}

class GetHomePreferencesBloc extends Bloc<GetHomePreferencesEvent, HomePreferencesBaseState> {
  SharedPreferences prefs;

  GetHomePreferencesBloc() : super(HomePreferencesInitialState()) {
    on<GetHomePreferencesEvent>((event, emit) async {
      if (event.status == HomeEventStatus.GET_PREFERENCES) {
        await _handleGetPreferencesState(event, emit);
      }
    },
    transformer: sequential());
  }

  Future<void> _handleGetPreferencesState(GetHomePreferencesEvent event, Emitter<HomePreferencesBaseState> emit) async {
    final HomePreferencesState result = await _getPreferences(event.value);
    emit(result);
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
      if (contextLanguageCode != null) {
        await prefs.setString('prefered_language_code', contextLanguageCode);
      } else {
        print('not setting contextLanguageCode, it\'s null');
      }
    }

    languageCode = prefs.getString('prefered_language_code');

    return HomePreferencesState(
      languageCode: languageCode,
      doSkip: doSkip,
      memberPk: memberPk);
  }
}
