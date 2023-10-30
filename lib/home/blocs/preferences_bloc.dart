import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/home/blocs/preferences_states.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HomeEventStatus { GET_PREFERENCES }

class GetHomePreferencesEvent {
  final String? value;
  final HomeEventStatus? status;

  const GetHomePreferencesEvent({this.value, this.status});
}

class GetHomePreferencesBloc extends Bloc<GetHomePreferencesEvent, HomePreferencesBaseState> {
  late SharedPreferences prefs;

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

  Future<HomePreferencesState> _getPreferences(String? contextLanguageCode) async {
    prefs = await SharedPreferences.getInstance();
    bool doSkip = false;
    String? languageCode;
    int? memberPk;

    if (prefs.containsKey('skip_member_list')) {
      doSkip = prefs.getBool('skip_member_list')!;
      memberPk = await utils.getPreferredMemberPk();
    }

    // check the default language
    if (!prefs.containsKey('prefered_language_code')) {
      if (contextLanguageCode != null) {
        await prefs.setString('preferred_language_code', contextLanguageCode);
      } else {
        print('not setting contextLanguageCode, it\'s null');
      }
    } else {
      languageCode = prefs.getString('prefered_language_code');
      if (languageCode != null) {
        await prefs.setString('preferred_language_code', languageCode);
      }
    }

    languageCode = prefs.getString('preferred_language_code');
    print('doSkip: $doSkip, memberPk: $memberPk');

    return HomePreferencesState(
      languageCode: languageCode,
      doSkip: doSkip,
      memberPk: memberPk,
    );
  }
}
