import 'package:test/test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/core/blocs/preferences.dart';

Future setupPreferences(String key, String value) async {
  SharedPreferences.setMockInitialValues(<String, dynamic>{'flutter.' + key: value});
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(key, value);
}

void main() {
  test('Test member API get URL', () async {
    await setupPreferences('companycode', 'test');
    final block = PreferencesBloc();
    block.incrementCounter.add('HOI');
  });

}
