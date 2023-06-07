import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/mobile/models/workorder/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/mobile/blocs/workorder_bloc.dart';
import 'package:my24app/mobile/blocs/workorder_states.dart';
import 'package:my24app/mobile/models/workorder/form_data.dart';

import 'fixtures.dart';
import 'http_client.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test workorder new', () async {
    final workorderBloc = WorkorderBloc();

    workorderBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<WorkorderDataNewState>());
          expect(event.props[0], isA<AssignedOrderWorkOrderFormData>());
        })
    );

    workorderBloc.add(
        WorkorderEvent(
            status: WorkorderEventStatus.NEW,
            assignedOrderId: 1
        )
    );
  });

  test('Test workorder insert', () async {
    final client = MockClient();
    final activityBloc = WorkorderBloc();
    activityBloc.api.httpClient = client;

    AssignedOrderWorkOrder workOrder = AssignedOrderWorkOrder(
      assignedOrderId: 1,
      assignedOrderWorkorderId: "1234",
      descriptionWork: "test",
      equipment: "bla",
      signatureUser: "87364587gd8q623",
      signatureCustomer: "87364587gd8q623",
      signatureNameUser: "user",
      signatureNameCustomer: "customer",
      customerEmails: "bla@bla.com",
    );

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return activity data with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorder-workorder/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(workorderData, 201));

    AssignedOrderWorkOrder newWorkorder = await activityBloc.api.insert(workOrder);
    expect(newWorkorder, isA<AssignedOrderWorkOrder>());
  });
}
