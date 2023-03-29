import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/order/pages/sales_list.dart';
import 'package:my24app/order/widgets/order/sales/empty.dart';
import 'package:my24app/order/widgets/order/sales/error.dart';
import 'package:my24app/order/widgets/order/sales/list.dart';
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

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

    orderBloc.api.httpClient = client;
    orderBloc.api.localUtils.httpClient = client;

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
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/sales_orders/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    SalesPage widget = SalesPage(bloc: orderBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(SalesListWidget), findsOneWidget);
    expect(find.byType(SalesListErrorWidget), findsNothing);
    expect(find.byType(SalesListEmptyWidget), findsNothing);
  });

  testWidgets('loads main list empty', (tester) async {
    final client = MockClient();
    final orderBloc = OrderBloc();

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

    orderBloc.api.httpClient = client;
    orderBloc.api.localUtils.httpClient = client;

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
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/sales_orders/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    SalesPage widget = SalesPage(bloc: orderBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(SalesListWidget), findsNothing);
    expect(find.byType(SalesListErrorWidget), findsNothing);
    expect(find.byType(SalesListEmptyWidget), findsOneWidget);
  });

  testWidgets('loads main list error', (tester) async {
    final client = MockClient();
    final orderBloc = OrderBloc();

    SharedPreferences.setMockInitialValues({
      'member_has_branches': false,
      'submodel': 'planning_user'
    });

    orderBloc.api.httpClient = client;
    orderBloc.api.localUtils.httpClient = client;

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
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/sales_orders/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orders, 500));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    SalesPage widget = SalesPage(bloc: orderBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(SalesListWidget), findsNothing);
    expect(find.byType(SalesListErrorWidget), findsOneWidget);
    expect(find.byType(SalesListEmptyWidget), findsNothing);
  });
}
