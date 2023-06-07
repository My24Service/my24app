import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/mobile/models/assign/form_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/mobile/blocs/assign_states.dart';
import 'package:my24app/mobile/blocs/assign_bloc.dart';
import 'http_client.mocks.dart';
import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('assign to engineer', () async {
    final client = MockClient();
    final AssignBloc assignBloc = AssignBloc();
    assignBloc.localMobileApi.httpClient = client;

    // return token request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
        headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(tokenData, 200));

    // return result with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/mobile/assign-user/1/'),
        headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('', 200));

    assignBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<AssignedState>());
          expect(event.props[0], isA<bool>());
          expect(event.props[0], true);
        })
    );

    expectLater(assignBloc.stream, emits(isA<AssignedState>()));
    final formData = AssignOrderFormData();
    formData.selectedEngineerPks = [1];

    assignBloc.add(
        AssignEvent(
            status: AssignEventStatus.ASSIGN,
            formData: formData,
            orderId: '15616546'
        )
    );
  });
}
