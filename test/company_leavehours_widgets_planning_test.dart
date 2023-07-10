import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/company/pages/leavehours.dart';
import 'package:my24app/company/widgets/leavehours/form.dart';
import 'package:my24app/company/widgets/leavehours/empty.dart';
import 'package:my24app/company/widgets/leavehours/error.dart';
import 'package:my24app/company/widgets/leavehours/list.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'fixtures.dart';
import 'http_client.mocks.dart';

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

  testWidgets('finds list - planning user', (tester) async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.planningApi.httpClient = client;

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

    // return leavehours data with a 200
    final String userLeaveHoursDataResult = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveHourData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(userLeaveHoursDataResult, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    UserLeaveHoursPage widget = UserLeaveHoursPage(bloc: userLeaveHoursBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UserLeaveHoursListEmptyWidget), findsNothing);
    expect(find.byType(UserLeaveHoursListErrorWidget), findsNothing);
    expect(find.byType(UserLeaveHoursListWidget), findsOneWidget);
  });

  testWidgets('finds empty - planning user', (tester) async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.planningApi.httpClient = client;

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

    // return leavehours data with a 200
    final String userLeaveHoursDataResult = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(userLeaveHoursDataResult, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    UserLeaveHoursPage widget = UserLeaveHoursPage(bloc: userLeaveHoursBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UserLeaveHoursListEmptyWidget), findsOneWidget);
    expect(find.byType(UserLeaveHoursListErrorWidget), findsNothing);
    expect(find.byType(UserLeaveHoursListWidget), findsNothing);
  });

  testWidgets('finds error - planning user', (tester) async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.planningApi.httpClient = client;

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

    // return leavehours data with a 500
    final String userLeaveHoursDataResult = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(userLeaveHoursDataResult, 500));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    UserLeaveHoursPage widget = UserLeaveHoursPage(bloc: userLeaveHoursBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UserLeaveHoursListEmptyWidget), findsNothing);
    expect(find.byType(UserLeaveHoursListErrorWidget), findsOneWidget);
    expect(find.byType(UserLeaveHoursListWidget), findsNothing);
  });

  testWidgets('finds form edit - planning user', (tester) async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.planningApi.httpClient = client;
    userLeaveHoursBloc.leaveTypeApi.httpClient = client;

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

    // return totals data with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/get_totals/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(leaveHourTotalsData, 200));

    // return leave type data with a 200
    final String leaveTypesData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveTypeData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/list_for_select/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(leaveTypesData, 200));

    // return leavehours data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(leaveHourData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    UserLeaveHoursPage widget = UserLeaveHoursPage(
      bloc: userLeaveHoursBloc,
      initialMode: 'form',
      pk: 1,
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UserLeaveHoursListEmptyWidget), findsNothing);
    expect(find.byType(UserLeaveHoursListErrorWidget), findsNothing);
    expect(find.byType(UserLeaveHoursListWidget), findsNothing);
    expect(find.byType(UserLeaveHoursFormWidget), findsOneWidget);
  });

  testWidgets('finds form new - planning user', (tester) async {
    final client = MockClient();
    final userLeaveHoursBloc = UserLeaveHoursBloc();
    userLeaveHoursBloc.api.httpClient = client;
    userLeaveHoursBloc.planningApi.httpClient = client;
    userLeaveHoursBloc.leaveTypeApi.httpClient = client;

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

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    // return totals data with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/company/user-leave-hours/admin/get_totals/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(leaveHourTotalsData, 200));

    // return leave type data with a 200
    final String leaveTypesData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$leaveTypeData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/list_for_select/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(leaveTypesData, 200));

    UserLeaveHoursPage widget = UserLeaveHoursPage(
        bloc: userLeaveHoursBloc,
        initialMode: 'new'
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(UserLeaveHoursListEmptyWidget), findsNothing);
    expect(find.byType(UserLeaveHoursListErrorWidget), findsNothing);
    expect(find.byType(UserLeaveHoursListWidget), findsNothing);
    expect(find.byType(UserLeaveHoursFormWidget), findsOneWidget);
  });
}
