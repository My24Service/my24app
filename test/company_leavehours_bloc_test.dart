import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/company/models/leavehours/form_data.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24app/company/blocs/leavehours_states.dart';
import 'fixtures.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all leavehours - normal user', () async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leavehours data with a 200
    final String userLeavehoursDataResult = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveHourData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(userLeavehoursDataResult, 200));

    userLeaveHoursBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<UserLeaveHoursPaginatedLoadedState>());
        expect(event.props[0], isA<UserLeaveHoursPaginated>());
      })
    );

    expectLater(userLeaveHoursBloc.stream, emits(isA<UserLeaveHoursPaginatedLoadedState>()));

    userLeaveHoursBloc.add(
        UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.FETCH_ALL,
            isPlanning: false
        ));
  });

  test('Test fetch all unaccepted leavehours - normal user', () async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.api.localUtils.httpClient = client;
    userLeaveHoursBloc.planningApi.httpClient = client;
    userLeaveHoursBloc.planningApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leavehours data with a 200
    final String userLeavehoursDataResult = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveHourData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/all_not_accepted/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(userLeavehoursDataResult, 200));

    userLeaveHoursBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<UserLeaveHoursUnacceptedPaginatedLoadedState>());
          expect(event.props[0], isA<UserLeaveHoursPaginated>());
        })
    );

    expectLater(userLeaveHoursBloc.stream, emits(isA<UserLeaveHoursUnacceptedPaginatedLoadedState>()));

    userLeaveHoursBloc.add(
        UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.FETCH_UNACCEPTED,
            isPlanning: false
        ));
  });

  test('Test leavehours delete - normal user', () async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leavehours data with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    userLeaveHoursBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<UserLeaveHoursDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(userLeaveHoursBloc.stream, emits(isA<UserLeaveHoursDeletedState>()));

    userLeaveHoursBloc.add(
        UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.DELETE,
            pk: 1,
            isPlanning: false
        ));
  });

  test('Test leavehours insert - normal user', () async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.api.localUtils.httpClient = client;
    userLeaveHoursBloc.leaveTypeApi.httpClient = client;
    userLeaveHoursBloc.leaveTypeApi.localUtils.httpClient = client;

    UserLeaveHours leaveHours = UserLeaveHours(
      leaveType: 1,
      startDate: "2023-04-23",
      endDate: "2023-04-23",
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leave type data with a 200
    final String leaveTypesData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveTypeData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/list_for_select/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(leaveTypesData, 200));

    // return leavehours data with a 201
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(leaveHourData, 201));

    final UserLeaveHours newUserLeaveHours = await userLeaveHoursBloc.api.insert(leaveHours);
    expect(newUserLeaveHours, isA<UserLeaveHours>());
  });

  test('Test leavehours new - normal user', () async {
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    final client = MockClient();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.api.localUtils.httpClient = client;
    userLeaveHoursBloc.leaveTypeApi.httpClient = client;
    userLeaveHoursBloc.leaveTypeApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leave type data with a 200
    final String leaveTypesData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveTypeData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/list_for_select/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(leaveTypesData, 200));

    userLeaveHoursBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<UserLeaveHoursNewState>());
          expect(event.props[0], isA<UserLeaveHoursFormData>());
        })
    );

    userLeaveHoursBloc.add(
        UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.NEW,
            isPlanning: false
        )
    );
  });

  // planning
  test('Test fetch all leavehours - planning user', () async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.api.localUtils.httpClient = client;
    userLeaveHoursBloc.planningApi.httpClient = client;
    userLeaveHoursBloc.planningApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leavehours data with a 200
    final String userLeavehoursDataResult = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveHourData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(userLeavehoursDataResult, 200));

    userLeaveHoursBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<UserLeaveHoursPaginatedLoadedState>());
          expect(event.props[0], isA<UserLeaveHoursPaginated>());
        })
    );

    expectLater(userLeaveHoursBloc.stream, emits(isA<UserLeaveHoursPaginatedLoadedState>()));

    userLeaveHoursBloc.add(
        UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.FETCH_ALL,
            isPlanning: true
        ));
  });

  test('Test fetch all unaccepted leavehours - planning user', () async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.api.localUtils.httpClient = client;
    userLeaveHoursBloc.planningApi.httpClient = client;
    userLeaveHoursBloc.planningApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leavehours data with a 200
    final String userLeavehoursDataResult = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveHourData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/all_not_accepted/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(userLeavehoursDataResult, 200));

    userLeaveHoursBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<UserLeaveHoursUnacceptedPaginatedLoadedState>());
          expect(event.props[0], isA<UserLeaveHoursPaginated>());
        })
    );

    expectLater(userLeaveHoursBloc.stream, emits(isA<UserLeaveHoursUnacceptedPaginatedLoadedState>()));

    userLeaveHoursBloc.add(
        UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.FETCH_UNACCEPTED,
            isPlanning: true
        ));
  });

  test('Test leavehours delete - planning user', () async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.api.localUtils.httpClient = client;
    userLeaveHoursBloc.planningApi.httpClient = client;
    userLeaveHoursBloc.planningApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leavehours data with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    userLeaveHoursBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<UserLeaveHoursDeletedState>());
          expect(event.props[0], true);
        })
    );

    expectLater(userLeaveHoursBloc.stream, emits(isA<UserLeaveHoursDeletedState>()));

    userLeaveHoursBloc.add(
        UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.DELETE,
            pk: 1,
            isPlanning: true
        ));
  });

  test('Test leavehours insert - planning user', () async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.api.localUtils.httpClient = client;
    userLeaveHoursBloc.leaveTypeApi.httpClient = client;
    userLeaveHoursBloc.leaveTypeApi.localUtils.httpClient = client;
    userLeaveHoursBloc.planningApi.httpClient = client;
    userLeaveHoursBloc.planningApi.localUtils.httpClient = client;

    UserLeaveHours leaveHours = UserLeaveHours(
      leaveType: 1,
      startDate: "2023-04-23",
      endDate: "2023-04-23",
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leave type data with a 200
    final String leaveTypesData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveTypeData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/list_for_select/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(leaveTypesData, 200));

    // return leavehours data with a 201
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(leaveHourData, 201));

    final UserLeaveHours newUserLeaveHours = await userLeaveHoursBloc.planningApi.insert(leaveHours);
    expect(newUserLeaveHours, isA<UserLeaveHours>());
  });

  test('Test leavehours accept - planning user', () async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.planningApi.httpClient = client;
    userLeaveHoursBloc.planningApi.localUtils.httpClient = client;

    UserLeaveHours leaveHours = UserLeaveHours(
      leaveType: 1,
      startDate: "2023-04-23",
      endDate: "2023-04-23",
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return result with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/1/set_accepted/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response('{result: true}', 200));

    userLeaveHoursBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<UserLeaveHoursAcceptedState>());
          expect(event.props[0], isA<bool>());
        })
    );

    userLeaveHoursBloc.add(
        UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.ACCEPT,
            pk: 1
        )
    );
  });

  test('Test leavehours reject - planning user', () async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.planningApi.httpClient = client;
    userLeaveHoursBloc.planningApi.localUtils.httpClient = client;

    UserLeaveHours leaveHours = UserLeaveHours(
      leaveType: 1,
      startDate: "2023-04-23",
      endDate: "2023-04-23",
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return result with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/1/set_rejected/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response('{result: true}', 200));

    userLeaveHoursBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<UserLeaveHoursRejectedState>());
          expect(event.props[0], isA<bool>());
        })
    );

    userLeaveHoursBloc.add(
        UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.REJECT,
            pk: 1
        )
    );
  });

  test('Test leavehours new - planning user', () async {
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    final client = MockClient();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.api.localUtils.httpClient = client;
    userLeaveHoursBloc.leaveTypeApi.httpClient = client;
    userLeaveHoursBloc.leaveTypeApi.localUtils.httpClient = client;
    userLeaveHoursBloc.planningApi.httpClient = client;
    userLeaveHoursBloc.planningApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leave type data with a 200
    final String leaveTypesData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveTypeData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/list_for_select/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(leaveTypesData, 200));

    userLeaveHoursBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<UserLeaveHoursNewState>());
          expect(event.props[0], isA<UserLeaveHoursFormData>());
        })
    );

    userLeaveHoursBloc.add(
        UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.NEW,
            isPlanning: true
        )
    );
  });
}
