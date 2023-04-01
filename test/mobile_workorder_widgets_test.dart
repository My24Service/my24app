import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/mobile/pages/workorder.dart';
import 'package:my24app/mobile/widgets/workorder.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/mobile/blocs/workorder_bloc.dart';
import 'package:my24app/mobile/blocs/workorder_states.dart';
import 'package:my24app/mobile/models/workorder/form_data.dart';
import 'fixtures.dart';

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

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('finds widget', (tester) async {
    final client = MockClient();
    final workorderBloc = WorkorderBloc();
    workorderBloc.api.httpClient = client;
    workorderBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return workorder data with a 2000
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorder/1/get_workorder_sign_details/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(workorderSignData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    WorkorderPage widget = WorkorderPage(
      assignedOrderId: 1, bloc: workorderBloc,
    );
    widget.utils.httpClient = client;
    widget.assignedOrderApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(WorkorderWidget), findsOneWidget);
  });
}
