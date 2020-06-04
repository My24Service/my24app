import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import 'package:my24app/login.dart';
import 'package:my24app/models.dart';
import 'fixtures.dart';

class MockClient extends Mock implements http.Client {}

main() {
  group('attemptLogIn', () {
    test('returns a Token object if the http call completes successfully with a valid Token object', () async {
      final client = MockClient();
      SharedPreferences.setMockInitialValues({
        'companycode': 'demo',
        'apiBaseUrl': 'my24service-dev.com'
      });

      var today = new DateTime.now();
      final key = 's3cr3t';
      final claimSet = new JwtClaim(
          subject: 'kleak',
          issuer: 'teja',
          expiry: today.add(new Duration(minutes: 5)),
          maxAge: const Duration(minutes: 5)
      );

      String tokenString = issueJwtHS256(claimSet, key);

      var response = '{"refresh": "$tokenString","access":"$tokenString"}';

      when(client.post('https://demo.my24service-dev.com/api/token/', body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(response, 200));

      var token = await attemptLogIn(client, 'user', 'password');

      expect(token, const TypeMatcher<Token>());
      expect(token.isValid, true);
    });

    test('returns Token.isValid with a invalid token', () async {
      final client = MockClient();
      SharedPreferences.setMockInitialValues({
        'companycode': 'demo',
        'apiBaseUrl': 'my24service-dev.com'
      });

      var response = '{"refresh":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1OTExODk4NjcsImlhdCI6MTU5MTE4OTU2NywiaXNzIjoidGVqYSIsInN1YiI6ImtsZWFrIn0ZOugDJAt-6vaM6T77QGDijPhjeKI2EXUB1IWDceG-ZE","access":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNTkxMTc3NTIxLCJqdGkiOiI3NmE1MzhiOTUzNDI0N2MxODgwMGZlNDJhYmYxNjdiZSIsInVzZXJfaWQiOjR9GEWnR9YMdiVHyWpew1wbfAkCeAvQvnmE5R-pU9cTSco"}';

      when(client.post('https://demo.my24service-dev.com/api/token/', body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(response, 200));

      var token = await attemptLogIn(client, 'user', 'password');

      expect(token.isValid, false);
    });

    test('returns Token.isExpired when the token is expired', () async {
      final client = MockClient();
      SharedPreferences.setMockInitialValues({
        'companycode': 'demo',
        'apiBaseUrl': 'my24service-dev.com'
      });

      var today = new DateTime.now();
      final key = 's3cr3t';
      final claimSet = new JwtClaim(
          subject: 'kleak',
          issuer: 'teja',
          expiry: today.add(new Duration(minutes: -5)),
          maxAge: const Duration(minutes: 5)
      );

      String tokenString = issueJwtHS256(claimSet, key);

      var response = '{"refresh": "$tokenString","access":"$tokenString"}';

      when(client.post('https://demo.my24service-dev.com/api/token/', body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(response, 200));

      var token = await attemptLogIn(client, 'user', 'password');

      expect(token.isValid, true);
      expect(token.isExpired, true);
    });
  });

  group('getUserInfo', () {
    test('returns a Engineer object if the http call completes successfully', () async {
      final client = MockClient();
      SharedPreferences.setMockInitialValues({
        'companycode': 'demo',
        'apiBaseUrl': 'my24service-dev.com'
      });

      final pk = 3;
      final accessToken = '534987f89dgsg9';

      when(client.get('https://demo.my24service-dev.com/company/user-info/$pk/',
          headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(userInfoEngineer, 200));

      var user = await getUserInfo(client, pk, accessToken);

      expect(user, const TypeMatcher<Engineer>());
    });
  });
}

