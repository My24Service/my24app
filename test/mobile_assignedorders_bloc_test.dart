import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/mobile/blocs/assignedorder_states.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/models/assignedorder/models.dart';
import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch assigned orders', () async {
    final preferences = await SharedPreferences.getInstance();
    final client = MockClient();
    final AssignedOrderBloc assignedOrderBloc = AssignedOrderBloc();
    assignedOrderBloc.api.httpClient = client;

    preferences.setInt('user_id', 1);
    preferences.setString('token', 'hsfudbsafdsuybafuysdbfua');
    preferences.setBool('fcm_allowed', false);

    // return token request with a 200
    when(client.post(
      Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
      headers: anyNamed('headers'), body: anyNamed('body'))
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return assigned orders request with a 200
    final assignedOrdersData = '{"next": null,"previous": null,"count": 1,"num_pages": 1,"results": [{"id": 7183,"engineer": 22,"student_user": null,"order": {"id": 6484,"customer_id": "1018","order_id": "19416","total_price_purchase": "0.00","total_price_selling": "0.00"},"started": "-","ended": "-"}]}';
    when(client.get(
      Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorder/list_app/'),
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

  test('Test fetch assigned order', () async {
    final client = MockClient();
    final AssignedOrderBloc assignedOrderBloc = AssignedOrderBloc();
    assignedOrderBloc.api.httpClient = client;

    // return token request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
        headers: anyNamed('headers'), body: anyNamed('body'))
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return assigned order request with a 200
    final assignedOrderData = '{"id": 7183,"engineer": 22,"student_user": null,"order": {"id": 6484,"customer_id": "1018","order_id": "19416","total_price_purchase": "0.00","total_price_selling": "0.00"},"started": "-","ended": "-"}';
    when(client.get(
        Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorder/1/detail_device/'),
        headers: anyNamed('headers'))
    ).thenAnswer((_) async => http.Response(assignedOrderData, 200));

    assignedOrderBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<AssignedOrderLoadedState>());
          expect(event.props[0], isA<AssignedOrder>());
        })
    );

    expectLater(assignedOrderBloc.stream, emits(isA<AssignedOrderLoadedState>()));

    assignedOrderBloc.add(
        AssignedOrderEvent(
            status: AssignedOrderEventStatus.FETCH_DETAIL,
            pk: 1
        )
    );
  });

  test('Test report start order', () async {
    final client = MockClient();
    final AssignedOrderBloc assignedOrderBloc = AssignedOrderBloc();
    assignedOrderBloc.api.httpClient = client;

    // return token request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
        headers: anyNamed('headers'), body: anyNamed('body'))
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return start order request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorder/1/report_statuscode/'),
        headers: anyNamed('headers'), body: anyNamed('body'))
    ).thenAnswer((_) async => http.Response('', 200));

    assignedOrderBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<AssignedOrderReportStartCodeState>());
          expect(event.props[0], true);
        })
    );

    expectLater(assignedOrderBloc.stream, emits(isA<AssignedOrderReportStartCodeState>()));

    StartCode startCode = StartCode(
      statuscode: 'test'
    );

    assignedOrderBloc.add(
        AssignedOrderEvent(
            status: AssignedOrderEventStatus.REPORT_STARTCODE,
            pk: 1,
            code: startCode
        )
    );
  });

  test('Test report end order', () async {
    final client = MockClient();
    final AssignedOrderBloc assignedOrderBloc = AssignedOrderBloc();
    assignedOrderBloc.api.httpClient = client;

    // return token request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
        headers: anyNamed('headers'), body: anyNamed('body'))
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return end order request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorder/1/report_statuscode/'),
        headers: anyNamed('headers'), body: anyNamed('body'))
    ).thenAnswer((_) async => http.Response('', 200));

    assignedOrderBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<AssignedOrderReportEndCodeState>());
          expect(event.props[0], true);
        })
    );

    expectLater(assignedOrderBloc.stream, emits(isA<AssignedOrderReportEndCodeState>()));

    EndCode endCode = EndCode(
        statuscode: 'test'
    );

    assignedOrderBloc.add(
        AssignedOrderEvent(
            status: AssignedOrderEventStatus.REPORT_ENDCODE,
            pk: 1,
            code: endCode
        )
    );
  });

  test('Test report extra work', () async {
    final client = MockClient();
    final AssignedOrderBloc assignedOrderBloc = AssignedOrderBloc();
    assignedOrderBloc.api.httpClient = client;

    // return token request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
        headers: anyNamed('headers'), body: anyNamed('body'))
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return extra work request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorder/1/create_extra_order/'),
        headers: anyNamed('headers'), body: anyNamed('body'))
    ).thenAnswer((_) async => http.Response('{"new_assigned_order": 2}', 200));

    assignedOrderBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<AssignedOrderReportExtraOrderState>());
          expect(event.props[0], {"new_assigned_order": 2});
        })
    );

    expectLater(assignedOrderBloc.stream, emits(isA<AssignedOrderReportExtraOrderState>()));

    assignedOrderBloc.add(
        AssignedOrderEvent(
            status: AssignedOrderEventStatus.REPORT_EXTRAWORK,
            pk: 1
        )
    );
  });

  test('Test report extra work', () async {
    final client = MockClient();
    final AssignedOrderBloc assignedOrderBloc = AssignedOrderBloc();
    assignedOrderBloc.api.httpClient = client;

    // return token request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
        headers: anyNamed('headers'), body: anyNamed('body'))
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return no workorder finished request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorder/1/no_workorder_finished/'),
        headers: anyNamed('headers'), body: anyNamed('body'))
    ).thenAnswer((_) async => http.Response('{"new_assigned_order": 2}', 200));

    assignedOrderBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<AssignedOrderReportNoWorkorderFinishedState>());
          expect(event.props[0], true);
        })
    );

    expectLater(assignedOrderBloc.stream, emits(isA<AssignedOrderReportNoWorkorderFinishedState>()));

    assignedOrderBloc.add(
        AssignedOrderEvent(
            status: AssignedOrderEventStatus.REPORT_NOWORKORDER,
            pk: 1
        )
    );
  });

}
