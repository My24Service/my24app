import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/dev_logging.dart';
import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/mobile/models/activity/form_data.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/blocs/activity_states.dart';
import 'package:my24app/mobile/models/activity/models.dart';
import 'fixtures.dart';
import 'functions.dart';

Widget createWidget({Widget? child}) {
  return MaterialApp(
    home: Scaffold(
        body: Container(
            child: child
        )
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setUpLogging();

  test('Test fetch all activities for an assigned order', () async {
    final client = MockClient();
    final activityBloc = ActivityBloc();
    activityBloc.api.httpClient = client;
    activityBloc.utils.httpClient = client;

    // initial data
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/get-initial-data/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(initialData, 200));

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

    activityBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<ActivitiesLoadedState>());
        expect(event.props[0], isA<AssignedOrderActivities>());
      })
    );

    expectLater(activityBloc.stream, emits(isA<ActivitiesLoadedState>()));

    activityBloc.add(
        ActivityEvent(
            status: ActivityEventStatus.FETCH_ALL,
            assignedOrderId: 1
        )
    );
  });

  test('Test activity insert', () async {
    final client = MockClient();
    final activityBloc = ActivityBloc();
    activityBloc.api.httpClient = client;
    activityBloc.utils.httpClient = client;

    // initial data
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/get-initial-data/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(initialData, 200));

    AssignedOrderActivity activity = AssignedOrderActivity(
      assignedOrderId: 1,
      workStart: "10:20:00",
      workEnd: "16:40:00",
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
        client.post(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderactivity/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(assignedOrderActivity, 201));

    AssignedOrderActivity newActivity = await activityBloc.api.insert(activity);
    expect(newActivity, isA<AssignedOrderActivity>());

    AssignedOrderActivityFormData formData = AssignedOrderActivityFormData.createFromModel(newActivity);
    expect(formData.workStartHourController!.text, "10");
    expect(formData.workStartMin, "40");
    expect(formData.workEndHourController!.text, "16");
    expect(formData.workEndMin, "50");
    expect(formData.travelToHourController!.text, "01");
    expect(formData.travelToMin, "05");
    expect(formData.travelBackHourController!.text, "02");
    expect(formData.travelBackMin, "25");
    expect(formData.extraWorkHourController!.text, "00");
    expect(formData.extraWorkMin, "35");
    expect(formData.actualWorkHourController!.text, "06");
    expect(formData.actualWorkMin, "00");
  });

  test('Test activity insert select engineers', () async {
    final client = MockClient();
    final activityBloc = ActivityBloc();
    activityBloc.api.httpClient = client;
    activityBloc.utils.httpClient = client;

    AssignedOrderActivity activity = AssignedOrderActivity(
      assignedOrderId: 1,
      workStart: "10:20:00",
      workEnd: "16:40:00",
    );

    // initial data
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/get-initial-data/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(getEngineersSelectInitialsData(), 200));

    // engineers
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/engineer/list-for-select/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(engineersForSelect, 200));

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return activity data with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderactivity/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(assignedOrderActivity, 201));

    AssignedOrderActivity newActivity = await activityBloc.api.insert(activity);
    expect(newActivity, isA<AssignedOrderActivity>());

    AssignedOrderActivityFormData formData = AssignedOrderActivityFormData.createFromModel(newActivity);
    expect(formData.workStartHourController!.text, "10");
    expect(formData.workStartMin, "40");
    expect(formData.workEndHourController!.text, "16");
    expect(formData.workEndMin, "50");
    expect(formData.travelToHourController!.text, "01");
    expect(formData.travelToMin, "05");
    expect(formData.travelBackHourController!.text, "02");
    expect(formData.travelBackMin, "25");
    expect(formData.extraWorkHourController!.text, "00");
    expect(formData.extraWorkMin, "35");
    expect(formData.actualWorkHourController!.text, "06");
    expect(formData.actualWorkMin, "00");
  });

  test('Test activity delete', () async {
    final client = MockClient();
    final activityBloc = ActivityBloc();
    activityBloc.api.httpClient = client;
    activityBloc.utils.httpClient = client;

    // initial data
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/get-initial-data/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(initialData, 200));

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return activity delete result with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderactivity/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    activityBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<ActivityDeletedState>());
        expect(event.props[0], true);
      })
    );

    activityBloc.add(
        ActivityEvent(
            status: ActivityEventStatus.DELETE,
            pk: 1,
            assignedOrderId: 1
        )
    );
  });

  test('Test activity new', () async {
    final client = MockClient();
    final activityBloc = ActivityBloc();
    activityBloc.utils.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // initial data
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/get-initial-data/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(initialData, 200));

    activityBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<ActivityNewState>());
          expect(event.props[0], isA<AssignedOrderActivityFormData>());
        })
    );

    activityBloc.add(
        ActivityEvent(
            status: ActivityEventStatus.NEW,
            assignedOrderId: 1
        )
    );
  });
}
