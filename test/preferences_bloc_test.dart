import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/core/blocs/preferences.dart';

Future setupPreferences(String key, String value) async {
  SharedPreferences.setMockInitialValues(<String, dynamic>{'flutter.' + key: value});
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(key, value);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test get preferences', () async {
    final preferencesBloc = PreferencesBloc();
    String _result;

    await setupPreferences('companycode', 'test');

    preferencesBloc.stream.listen((data) => {
      _result = data
    });

    expectLater(preferencesBloc.stream, emits('test'));

    preferencesBloc.add(PreferencesEvent(value: 'companycode', status: EventStatus.READ));
  });
}
