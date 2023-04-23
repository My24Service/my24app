import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/company/models/workhours/form_data.dart';
import 'package:my24app/company/models/workhours/models.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'package:my24app/company/blocs/workhours_states.dart';
import 'fixtures.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all workhours', () async {
    final client = MockClient();
    final userWorkHoursBloc = UserWorkHoursBloc();
    userWorkHoursBloc.api.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return workhour data with a 200
    final String userWorkhoursDataResult = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$userWorkhoursData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-workhours/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(userWorkhoursDataResult, 200));

    userWorkHoursBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<UserWorkHoursPaginatedLoadedState>());
        expect(event.props[0], isA<UserWorkHoursPaginated>());
      })
    );

    expectLater(userWorkHoursBloc.stream, emits(isA<UserWorkHoursPaginatedLoadedState>()));

    userWorkHoursBloc.add(
        UserWorkHoursEvent(status: UserWorkHoursEventStatus.FETCH_ALL));
  });

  test('Test workhours delete', () async {
    final client = MockClient();
    final userWorkHoursBloc = UserWorkHoursBloc();
    userWorkHoursBloc.api.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return workhours data with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/api/company/user-workhours/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    userWorkHoursBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<UserWorkHoursDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(userWorkHoursBloc.stream, emits(isA<UserWorkHoursDeletedState>()));

    userWorkHoursBloc.add(
        UserWorkHoursEvent(status: UserWorkHoursEventStatus.DELETE, pk: 1));
  });

  test('Test workhours insert', () async {
    final client = MockClient();
    final userWorkHoursBloc = UserWorkHoursBloc();
    userWorkHoursBloc.api.httpClient = client;

    UserWorkHours workHours = UserWorkHours(
      project: 1,
      workStart: "10:20:00",
      workEnd: "16:40:00",
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return project data with a 200
    final String projectsData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$projectData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/project/list_for_select/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(projectsData, 200));

    // return workhour data with a 201
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/company/user-workhours/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(userWorkhoursData, 201));

    final UserWorkHours newUserWorkHours = await userWorkHoursBloc.api.insert(workHours);
    expect(newUserWorkHours, isA<UserWorkHours>());
  });

  test('Test workhours new', () async {
    final userWorkHoursBloc = UserWorkHoursBloc();
    final client = MockClient();
    userWorkHoursBloc.api.httpClient = client;
    userWorkHoursBloc.projectApi.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return project data with a 200
    final String projectsData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$projectData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/project/list_for_select/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(projectsData, 200));

    userWorkHoursBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<UserWorkHoursNewState>());
          expect(event.props[0], isA<UserWorkHoursFormData>());
        })
    );

    userWorkHoursBloc.add(
        UserWorkHoursEvent(
            status: UserWorkHoursEventStatus.NEW,
        )
    );
  });
}
