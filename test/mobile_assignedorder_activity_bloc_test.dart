import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:my24app/mobile/models/activity/form_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/blocs/activity_states.dart';
import 'package:my24app/mobile/models/activity/models.dart';

class MockClient extends Mock implements http.Client {}

Widget createWidget({Widget child}) {
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

  test('Test fetch all activities for an assigned order', () async {
    final client = MockClient();
    final activityBloc = ActivityBloc();
    activityBloc.api.httpClient = client;
    activityBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return activity data with a 200
    final String activityData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "assignedOrderId": 1, "work_start": "10:30:00", "work_end": "15:20:02"}]}';
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
    activityBloc.api.localUtils.httpClient = client;

    AssignedOrderActivity activity = AssignedOrderActivity(
      assignedOrderId: 1,
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

    // return activity data with a 200
    final String activityData = '{"id":129,"assigned_order":309,"work_start":"10:40:00",'
        '"work_end":"16:50:00","travel_to":"01:05:00","travel_back":"02:25:00",'
        '"distance_to":25,"distance_back":50,"activity_date":"18/01/2023","extra_work":"00:35:00",'
        '"extra_work_description":"Test","distance_fixed_rate_amount":0,"actual_work":"06:00:00"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderactivity/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(activityData, 201));

    AssignedOrderActivity newActivity = await activityBloc.api.insert(activity);
    expect(newActivity, isA<AssignedOrderActivity>());

    AssignedOrderActivityFormData formData = AssignedOrderActivityFormData.createFromModel(newActivity);
    expect(formData.workStartHourController.text, "10");
    expect(formData.workStartMin, "40");
    expect(formData.workEndHourController.text, "16");
    expect(formData.workEndMin, "50");
    expect(formData.travelToHourController.text, "01");
    expect(formData.travelToMin, "05");
    expect(formData.travelBackHourController.text, "02");
    expect(formData.travelBackMin, "25");
    expect(formData.extraWorkHourController.text, "00");
    expect(formData.extraWorkMin, "35");
    expect(formData.actualWorkHourController.text, "06");
    expect(formData.actualWorkMin, "00");
  });

  test('Test activity delete', () async {
    final client = MockClient();
    final activityBloc = ActivityBloc();
    activityBloc.api.httpClient = client;
    activityBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
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

    // expectLater(activityBloc.stream, emits(isA<ActivityDeletedState>()));

    activityBloc.add(
        ActivityEvent(
            status: ActivityEventStatus.DELETE,
            pk: 1,
            assignedOrderId: 1
        )
    );
  });

}
