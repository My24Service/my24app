import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/mobile/widgets/activity/form.dart';
import 'package:my24app/mobile/pages/activity.dart';
import 'package:my24app/mobile/widgets/activity/error.dart';
import 'package:my24app/mobile/widgets/activity/list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
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
    final activityBloc = ActivityBloc();
    activityBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return activity data with a 200
    final String activityData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$assignedOrderActivity]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderactivity/?assigned_order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(activityData, 200));

    AssignedOrderActivityPage widget = AssignedOrderActivityPage(assignedOrderId: 1, bloc: activityBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(ActivityFormWidget), findsNothing);
    expect(find.byType(ActivityListErrorWidget), findsNothing);
    expect(find.byType(ActivityListWidget), findsOneWidget);
  });

  testWidgets('finds empty', (tester) async {
    final client = MockClient();
    final activityBloc = ActivityBloc();
    activityBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return activity data with a 200
    final String activityData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderactivity/?assigned_order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(activityData, 200));

    AssignedOrderActivityPage widget = AssignedOrderActivityPage(assignedOrderId: 1, bloc: activityBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(ActivityFormWidget), findsOneWidget);
    expect(find.byType(ActivityListErrorWidget), findsNothing);
    expect(find.byType(ActivityListWidget), findsNothing);
  });

  testWidgets('finds error', (tester) async {
    final client = MockClient();
    final activityBloc = ActivityBloc();
    activityBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return activity data with a 500
    final String activityData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderactivity/?assigned_order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(activityData, 500));

    AssignedOrderActivityPage widget = AssignedOrderActivityPage(assignedOrderId: 1, bloc: activityBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(ActivityFormWidget), findsNothing);
    expect(find.byType(ActivityListErrorWidget), findsOneWidget);
    expect(find.byType(ActivityListWidget), findsNothing);
  });

  testWidgets('finds form edit', (tester) async {
    final client = MockClient();
    final activityBloc = ActivityBloc();
    activityBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return activity data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderactivity/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(assignedOrderActivity, 200));

    AssignedOrderActivityPage widget = AssignedOrderActivityPage(
      assignedOrderId: 1, bloc: activityBloc,
      initialMode: 'form',
      pk: 1,
    );
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(ActivityListErrorWidget), findsNothing);
    expect(find.byType(ActivityListWidget), findsNothing);
    expect(find.byType(ActivityFormWidget), findsOneWidget);
  });

  testWidgets('finds form new', (tester) async {
    final client = MockClient();
    final activityBloc = ActivityBloc();
    activityBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    AssignedOrderActivityPage widget = AssignedOrderActivityPage(
      assignedOrderId: 1, bloc: activityBloc,
      initialMode: 'new'
    );
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(ActivityListErrorWidget), findsNothing);
    expect(find.byType(ActivityListWidget), findsNothing);
    expect(find.byType(ActivityFormWidget), findsOneWidget);
  });
}
