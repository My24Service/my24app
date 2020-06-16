import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import 'package:my24app/utils.dart';
import 'package:my24app/models.dart';


class MockClient extends Mock implements http.Client {}

main() {
  group('refreshToken', () {
    test(
        'returns a Token object if the http call completes successfully with a valid refresh Token object', () async {
      var today = new DateTime.now();
      final key = 's3cr3t';
      final claimSet = new JwtClaim(
          subject: 'kleak',
          issuer: 'teja',
          expiry: today.add(new Duration(minutes: 5)),
          maxAge: const Duration(minutes: 5)
      );

      String tokenString = issueJwtHS256(claimSet, key);

      final client = MockClient();
      SharedPreferences.setMockInitialValues({
        'companycode': 'demo',
        'apiBaseUrl': 'my24service-dev.com',
        'tokenRefresh': tokenString,
      });

      final String body = json.encode(<String, String>{"refresh": tokenString});
      final response = '{"access":"$tokenString"}';
      final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};

      when(client.post('https://demo.my24service-dev.com/api/token/refresh/',
          body: body, headers: headers))
          .thenAnswer((_) async => http.Response(response, 200));

      var token = await refreshToken(client);

      expect(token, const TypeMatcher<Token>());
    });
  });
}
