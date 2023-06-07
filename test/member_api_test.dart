import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/member/models/public/api.dart';

Future setupPreferences(String key, String value) async {
  SharedPreferences.setMockInitialValues(<String, String>{'flutter.' + key: value});
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(key, value);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test member API get URL', () async {
    final MemberListPublicApi memberApi = MemberListPublicApi();
    await setupPreferences('companycode', 'test');
    final String url = await memberApi.getUrl('/test/');

    expect(url, equals('https://test.my24service-dev.com/api/test/'));
  });
}
