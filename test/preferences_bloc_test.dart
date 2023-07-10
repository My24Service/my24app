import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/core/blocs/preferences.dart';

Future setupPreferences(String key, String value) async {
  SharedPreferences.setMockInitialValues(<String, String>{'flutter.' + key: value});
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(key, value);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test get preferences', () async {
    final preferencesBloc = PreferencesBloc();

    await setupPreferences('companycode', 'test');

    preferencesBloc.stream.listen((data) => {
      // _result = data
    });

    expectLater(preferencesBloc.stream, emits(isA<PreferencesReadState>()));

    preferencesBloc.add(PreferencesEvent(value: 'companycode', status: EventStatus.READ));
  });
}
