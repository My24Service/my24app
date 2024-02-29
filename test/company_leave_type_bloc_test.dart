import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/company/models/leave_type/form_data.dart';
import 'package:my24app/company/models/leave_type/models.dart';
import 'package:my24app/company/blocs/leave_type_bloc.dart';
import 'package:my24app/company/blocs/leave_type_states.dart';
import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all leave types', () async {
    final client = MockClient();
    final leaveTypeBloc = LeaveTypeBloc();
    leaveTypeBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leave types data with a 200
    final String leaveTypesData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveTypeData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(leaveTypesData, 200));

    leaveTypeBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<LeaveTypesLoadedState>());
        expect(event.props[0], isA<LeaveTypes>());
      })
    );

    expectLater(leaveTypeBloc.stream, emits(isA<LeaveTypesLoadedState>()));

    leaveTypeBloc.add(
        LeaveTypeEvent(status: LeaveTypeEventStatus.FETCH_ALL));
  });

  test('Test leave type delete', () async {
    final client = MockClient();
    final leaveTypeBloc = LeaveTypeBloc();
    leaveTypeBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return no content with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    leaveTypeBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<LeaveTypeDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(leaveTypeBloc.stream, emits(isA<LeaveTypeDeletedState>()));

    leaveTypeBloc.add(
        LeaveTypeEvent(status: LeaveTypeEventStatus.DELETE, pk: 1));
  });

  test('Test leave type insert', () async {
    final client = MockClient();
    final leaveTypeBloc = LeaveTypeBloc();
    leaveTypeBloc.api.httpClient = client;

    LeaveType leaveType = LeaveType(
      name: 'test',
    );

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leave type data with a 201
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(leaveTypeData, 201));

    final LeaveType newLeaveType = await leaveTypeBloc.api.insert(leaveType);
    expect(newLeaveType, isA<LeaveType>());
  });

  test('Test leave type new', () async {
    final leaveTypeBloc = LeaveTypeBloc();

    leaveTypeBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<LeaveTypeNewState>());
          expect(event.props[0], isA<LeaveTypeFormData>());
        })
    );

    leaveTypeBloc.add(
        LeaveTypeEvent(
            status: LeaveTypeEventStatus.NEW,
        )
    );
  });
}
