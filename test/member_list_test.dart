import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/member_list.dart';
import 'package:my24app/models.dart';


// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

main() {
  group('fetchMembers', () {
    test('returns a Members list if the http call completes successfully', () async {
      final client = MockClient();
      SharedPreferences.setMockInitialValues({
        'apiBaseUrl': 'my24service-dev.com'
      });

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.get('https://demo.my24service-dev.com/member/list-public/'))
          .thenAnswer((_) async => http.Response('{"results": [{"companycode": "Test companycode"}]}', 200));

      expect(await fetchMembers(client), const TypeMatcher<Members>());
    });

  });
}
