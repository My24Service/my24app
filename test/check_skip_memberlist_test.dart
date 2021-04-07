import 'package:test/test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/home/blocs/check_skip_memberlist.dart';

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

void main() {
  test('Test member list skip', () async {
    final checkMemberSkipBloc = CheckMemberSkipBloc();
    bool _result;

    await setPreferences('skip_member_list', true);
    await setPreferences('prefered_member_pk', 1);

    checkMemberSkipBloc.stream.listen((data) {
      _result = data;
    });

    expectLater(checkMemberSkipBloc.stream, emits(true));

    checkMemberSkipBloc.add(CheckMemberSkipEvent(status: EventStatus.CHECK));
  });

  test('Test not member list skip', () async {
    final checkMemberSkipBloc = CheckMemberSkipBloc();
    bool _result;

    await setPreferences('skip_member_list', false);
    await setPreferences('prefered_member_pk', 1);

    checkMemberSkipBloc.stream.listen((data) {
      _result = data;
    });

    expectLater(checkMemberSkipBloc.stream, emits(false));

    checkMemberSkipBloc.add(CheckMemberSkipEvent(status: EventStatus.CHECK));
  });
}
