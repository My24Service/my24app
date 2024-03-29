import 'package:flutter_test/flutter_test.dart';
import 'package:my24app/home/blocs/preferences_states.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/home/blocs/preferences_bloc.dart';

Future setPreferences(String key, dynamic value) async {
  final preferences = await SharedPreferences.getInstance();

  if (value is String) {
    await preferences.setString(key, value);
  }

  if (value is bool) {
    await preferences.setBool(key, value);
  }

  if (value is int) {
    await preferences.setInt(key, value);
  }
}


void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test get home preferences', () async {
    final checkMemberSkipBloc = GetHomePreferencesBloc();

    await setPreferences('skip_member_list', true);
    await setPreferences('prefered_member_pk', 1);

    checkMemberSkipBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<HomePreferencesState>());
        expect(event.props[0], 'en');  // languageCode
        expect(event.props[1], true);  // doSkip
      })
    );

    expectLater(checkMemberSkipBloc.stream, emits(isA<HomePreferencesState>()));

    checkMemberSkipBloc.add(
        GetHomePreferencesEvent(status: HomeEventStatus.GET_PREFERENCES, value: 'en'));
  });
}
