import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/member_list.dart';
import 'package:my24app/models.dart';


class MockClient extends Mock implements http.Client {}

main() {
  group('fetchMembers', () {
    test('returns a Members list if the http call completes successfully', () async {
      final client = MockClient();
      SharedPreferences.setMockInitialValues({
        'apiBaseUrl': 'my24service-dev.com'
      });

      when(client.get('https://demo.my24service-dev.com/member/list-public/'))
          .thenAnswer((_) async => http.Response('{"results": [{"companycode": "Test companycode"}]}', 200));

      expect(await fetchMembers(client), const TypeMatcher<Members>());
    });

  });
}
