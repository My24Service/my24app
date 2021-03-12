import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/main.dart';
import 'package:my24app/models.dart';
import 'fixtures.dart';

class MockClient extends Mock implements http.Client {}

main() {
  group('fetchMembers', () {
    test('returns a Members list if the http call completes successfully', () async {
      final client = MockClient();
      SharedPreferences.setMockInitialValues({
        'apiBaseUrl': 'my24service-dev.com'
      });

      when(client.get('https://demo.my24service-dev.com/member/list-public/'))
          .thenAnswer((_) async => http.Response(json.encode(memberList), 200, headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'}));

      expect(await fetchMembers(client), const TypeMatcher<Members>());
    });
  });

}
