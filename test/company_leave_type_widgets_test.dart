import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/company/pages/leave_type.dart';
import 'package:my24app/company/widgets/leave_type/form.dart';
import 'package:my24app/company/widgets/leave_type/error.dart';
import 'package:my24app/company/widgets/leave_type/list.dart';
import 'package:my24app/company/blocs/leave_type_bloc.dart';
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
    final leaveTypeBloc = LeaveTypeBloc();

    leaveTypeBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return leave type data with a 200
    final String leaveTypesData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": [$leaveTypeData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(leaveTypesData, 200));

    LeaveTypePage widget = LeaveTypePage(bloc: leaveTypeBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(LeaveTypeFormWidget), findsNothing);
    expect(find.byType(LeaveTypeListErrorWidget), findsNothing);
    expect(find.byType(LeaveTypeListWidget), findsOneWidget);
  });

  testWidgets('finds empty', (tester) async {
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

    // return project data with a 200
    final String projectsData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(projectsData, 200));

    LeaveTypePage widget = LeaveTypePage(bloc: leaveTypeBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(LeaveTypeFormWidget), findsOneWidget);
    expect(find.byType(LeaveTypeListErrorWidget), findsNothing);
    expect(find.byType(LeaveTypeListWidget), findsNothing);
  });

  testWidgets('finds error', (tester) async {
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

    // return with a 500
    final String projectsData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(projectsData, 500));

    LeaveTypePage widget = LeaveTypePage(bloc: leaveTypeBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(LeaveTypeFormWidget), findsNothing);
    expect(find.byType(LeaveTypeListErrorWidget), findsOneWidget);
    expect(find.byType(LeaveTypeListWidget), findsNothing);
  });

  testWidgets('finds form edit', (tester) async {
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

    // return leave type data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/leave-type/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(leaveTypeData, 200));

    LeaveTypePage widget = LeaveTypePage(
      bloc: leaveTypeBloc,
      initialMode: 'form',
      pk: 1,
    );
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(LeaveTypeListErrorWidget), findsNothing);
    expect(find.byType(LeaveTypeListWidget), findsNothing);
    expect(find.byType(LeaveTypeFormWidget), findsOneWidget);
  });

  testWidgets('finds form new', (tester) async {
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

    LeaveTypePage widget = LeaveTypePage(
      bloc: leaveTypeBloc,
      initialMode: 'new'
    );

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(LeaveTypeListErrorWidget), findsNothing);
    expect(find.byType(LeaveTypeListWidget), findsNothing);
    expect(find.byType(LeaveTypeFormWidget), findsOneWidget);
  });
}
