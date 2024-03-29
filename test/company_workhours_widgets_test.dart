import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/company/pages/workhours.dart';
import 'package:my24app/company/widgets/workhours/form.dart';
import 'package:my24app/company/widgets/workhours/error.dart';
import 'package:my24app/company/widgets/workhours/list.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'fixtures.dart';

Widget createWidget({Widget? child}) {
  return MaterialApp(
      home: Scaffold(
          body: Container(
              child: child
          )
      ),
  );
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('finds list', (tester) async {
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

    final DateTime startDate = coreUtils.getMonday();
    final String startDateTxt = coreUtils.formatDate(startDate);

    // return workhour data with a 200
    final String userWorkhoursDataResult = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$userWorkhoursData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-workhours/?start_date=$startDateTxt'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(userWorkhoursDataResult, 200));

    UserWorkHoursPage widget = UserWorkHoursPage(bloc: userWorkHoursBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UserWorkHoursListErrorWidget), findsNothing);
    expect(find.byType(UserWorkHoursListWidget), findsOneWidget);
  });

  testWidgets('finds error', (tester) async {
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

    // return workhour data with a 500
    final String userWorkhoursDataResult = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-workhours/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(userWorkhoursDataResult, 500));

    UserWorkHoursPage widget = UserWorkHoursPage(bloc: userWorkHoursBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UserWorkHoursListErrorWidget), findsOneWidget);
    expect(find.byType(UserWorkHoursListWidget), findsNothing);
  });

  testWidgets('finds form edit', (tester) async {
    final client = MockClient();
    final userWorkHoursBloc = UserWorkHoursBloc();
    userWorkHoursBloc.api.httpClient = client;
    userWorkHoursBloc.projectApi.httpClient = client;

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

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

    // return workhour data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-workhours/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(userWorkhoursData, 200));

    UserWorkHoursPage widget = UserWorkHoursPage(
      bloc: userWorkHoursBloc,
      initialMode: 'form',
      pk: 1,
    );
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UserWorkHoursListErrorWidget), findsNothing);
    expect(find.byType(UserWorkHoursListWidget), findsNothing);
    expect(find.byType(UserWorkHoursFormWidget), findsOneWidget);
  });

  testWidgets('finds form new', (tester) async {
    final client = MockClient();
    final userWorkHoursBloc = UserWorkHoursBloc();
    userWorkHoursBloc.api.httpClient = client;
    userWorkHoursBloc.projectApi.httpClient = client;

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

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

    UserWorkHoursPage widget = UserWorkHoursPage(
      bloc: userWorkHoursBloc,
      initialMode: 'new'
    );
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UserWorkHoursListErrorWidget), findsNothing);
    expect(find.byType(UserWorkHoursListWidget), findsNothing);
    expect(find.byType(UserWorkHoursFormWidget), findsOneWidget);
  });
}
