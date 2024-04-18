import 'package:flutter_test/flutter_test.dart';
import 'package:my24app/home/blocs/home_states.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/home/blocs/home_bloc.dart';

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
    final checkMemberSkipBloc = HomeBloc();

    await setPreferences('skip_member_list', true);
    await setPreferences('prefered_member_pk', 1);

    checkMemberSkipBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<HomeState>());
        expect(event.props[0], 'en');  // languageCode
        expect(event.props[1], true);  // doSkip
      })
    );

    expectLater(checkMemberSkipBloc.stream, emits(isA<HomeState>()));

    checkMemberSkipBloc.add(
        HomeEvent(status: HomeEventStatus.getPreferences, value: 'en'));
  });
}
