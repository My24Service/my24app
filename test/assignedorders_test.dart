import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/assignedorders_list.dart';
import 'package:my24app/models.dart';
import 'fixtures.dart';

class MockClient extends Mock implements http.Client {}

main() {
  group('fetchAssignedOrders', () {
    test(
        'returns a AssignedOrders list if the http call completes successfully', () async {
      final client = MockClient();
      SharedPreferences.setMockInitialValues({
        'apiBaseUrl': 'my24service-dev.com',
        'user_id': 3,
        'accessToken': '534987f89dgsg9',
      });

      when(client.get('https://demo.my24service-dev.com/mobile/assignedorder/list_app/?user_pk=3&json',
          headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(json.encode(assignedOrdersList), 200));

      expect(await fetchAssignedOrders(client), const TypeMatcher<AssignedOrders>());
    });
  });
}
