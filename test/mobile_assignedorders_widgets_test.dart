import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/mobile/widgets/assigned/list.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:my24app/mobile/pages/assigned.dart';
import 'package:my24app/mobile/widgets/assigned/detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
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

  testWidgets('loads list', (tester) async {
    final client = MockClient();
    final assignedOrderBloc = AssignedOrderBloc();

    assignedOrderBloc.api.httpClient = client;
    assignedOrderBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return assigned order data with a 200
    final String assignedOrders = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$assignedOrder]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorder/list_app/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(assignedOrders, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    AssignedOrdersPage widget = AssignedOrdersPage(
        bloc: assignedOrderBloc,
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(AssignedOrderListWidget), findsOneWidget);
    expect(find.byType(AssignedWidget), findsNothing);
  });

  testWidgets('loads detail', (tester) async {
    final client = MockClient();
    final assignedOrderBloc = AssignedOrderBloc();

    assignedOrderBloc.api.httpClient = client;
    assignedOrderBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return assigned order data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorder/1/detail_device/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(assignedOrder, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    AssignedOrdersPage widget = AssignedOrdersPage(
      pk: 1,
      bloc: assignedOrderBloc,
      initialMode: 'detail',
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(AssignedOrderListWidget), findsNothing);
    expect(find.byType(AssignedWidget), findsOneWidget);
  });
}
