import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/order/pages/past.dart';
import 'package:my24app/order/widgets/order/past/empty.dart';
import 'package:my24app/order/widgets/order/past/error.dart';
import 'package:my24app/order/widgets/order/past/list.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
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

  testWidgets('loads main list', (tester) async {
    final client = MockClient();
    final orderBloc = OrderBloc();
    orderBloc.api.httpClient = client;

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

    // return order data with a 200
    final String orders = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$order]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/past/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    PastPage widget = PastPage(bloc: orderBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(PastListWidget), findsOneWidget);
    expect(find.byType(PastListErrorWidget), findsNothing);
    expect(find.byType(PastListEmptyWidget), findsNothing);
  });

  testWidgets('loads main list empty', (tester) async {
    final client = MockClient();
    final orderBloc = OrderBloc();
    orderBloc.api.httpClient = client;

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

    // return nothing with a 200
    final String orders = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/past/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    PastPage widget = PastPage(bloc: orderBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(PastListErrorWidget), findsNothing);
    expect(find.byType(PastListEmptyWidget), findsOneWidget);
    expect(find.byType(PastListWidget), findsNothing);
  });

  testWidgets('loads main list error', (tester) async {
    final client = MockClient();
    final orderBloc = OrderBloc();
    orderBloc.api.httpClient = client;

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

    // return a 500
    final String orders = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/past/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 500));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    PastPage widget = PastPage(bloc: orderBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(PastListErrorWidget), findsOneWidget);
    expect(find.byType(PastListEmptyWidget), findsNothing);
    expect(find.byType(PastListWidget), findsNothing);
  });
}
