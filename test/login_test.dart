import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/login.dart';
import 'package:my24app/models.dart';
import 'fixtures.dart';

class MockClient extends Mock implements http.Client {}

main() {
  group('getUserInfo', () {
    test('returns a Engineer object if the http call completes successfully', () async {
      final client = MockClient();
      SharedPreferences.setMockInitialValues({
        'companycode': 'demo',
        'apiBaseUrl': 'my24service-dev.com',
        'token': '534987f89dgsg9',
      });

      final pk = 3;

      when(client.get('https://demo.my24service-dev.com/company/user-info/$pk/',
          headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(userInfoEngineer, 200));

      var user = await getUserInfo(client, pk);

      expect(user, const TypeMatcher<EngineerUser>());
    });
  });
}

