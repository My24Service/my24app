import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/mobile/blocs/assignedorder_states.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/models/models.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test fetch assigned orders', () async {
    final preferences = await SharedPreferences.getInstance();
    final client = MockClient();
    final AssignedOrderBloc assignedOrderBloc = AssignedOrderBloc(AssignedOrderInitialState());

    assignedOrderBloc.localMobileApi.httpClient = client;
    assignedOrderBloc.localMobileApi.localUtils.httpClient = client;

    preferences.setInt('user_id', 1);
    preferences.setString('token', 'hsfudbsafdsuybafuysdbfua');
    preferences.setBool('fcm_allowed', false);

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(
      Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'),
      headers: anyNamed('headers'), body: anyNamed('body'))
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return device token request with a 200
    final assignedOrdersData = '{"next": null,"previous": null,"count": 1,"num_pages": 1,"results": [{"id": 7183,"engineer": 22,"student_user": null,"order": {"id": 6484,"customer_id": "1018","order_id": "19416","total_price_purchase": "0.00","total_price_selling": "0.00"},"started": "-","ended": "-"}]}';
    when(client.get(
      Uri.parse('https://demo.my24service-dev.com/mobile/assignedorder/list_app/?user_pk=1'),
      headers: anyNamed('headers'))
    ).thenAnswer((_) async => http.Response(assignedOrdersData, 200));

    assignedOrderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<AssignedOrdersLoadedState>());
        expect(event.props[0], isA<AssignedOrders>());
      })
    );

    expectLater(assignedOrderBloc.stream, emits(isA<AssignedOrdersLoadedState>()));

    assignedOrderBloc.add(
      AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_ALL
      )
    );
  });
}
