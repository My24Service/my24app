import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/customer/widgets/detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:my24app/customer/pages/list_form.dart';
import 'package:my24app/customer/pages/detail.dart';
import 'package:my24app/customer/widgets/empty.dart';
import 'package:my24app/customer/widgets/error.dart';
import 'package:my24app/customer/widgets/list.dart';
import 'package:my24app/customer/widgets/form.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
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

  testWidgets('finds list', (tester) async {
    final client = MockClient();
    final customerBloc = CustomerBloc();
    customerBloc.api.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return Customer data with a 200
    final String customersData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$customerData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/customer/customer/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(customersData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    CustomerPage widget = CustomerPage(bloc: customerBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CustomerListEmptyWidget), findsNothing);
    expect(find.byType(CustomerListErrorWidget), findsNothing);
    expect(find.byType(CustomerListWidget), findsOneWidget);
  });

  testWidgets('finds empty', (tester) async {
    final client = MockClient();
    final customerBloc = CustomerBloc();
    customerBloc.api.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return Customer data with a 200
    final String customersData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/customer/customer/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(customersData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    CustomerPage widget = CustomerPage(bloc: customerBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CustomerListEmptyWidget), findsOneWidget);
    expect(find.byType(CustomerListErrorWidget), findsNothing);
    expect(find.byType(CustomerListWidget), findsNothing);
  });

  testWidgets('finds error', (tester) async {
    final client = MockClient();
    final customerBloc = CustomerBloc();
    customerBloc.api.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return Customer data with a 500
    final String customersData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/customer/customer/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(customersData, 500));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    CustomerPage widget = CustomerPage(bloc: customerBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CustomerListEmptyWidget), findsNothing);
    expect(find.byType(CustomerListErrorWidget), findsOneWidget);
    expect(find.byType(CustomerListWidget), findsNothing);
  });

  testWidgets('finds form edit', (tester) async {
    final client = MockClient();
    final customerBloc = CustomerBloc();
    customerBloc.api.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return Customer data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/customer/customer/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(customerData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    CustomerPage widget = CustomerPage(
      bloc: customerBloc,
      initialMode: 'form',
      pk: 1,
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CustomerListEmptyWidget), findsNothing);
    expect(find.byType(CustomerListErrorWidget), findsNothing);
    expect(find.byType(CustomerListWidget), findsNothing);
    expect(find.byType(CustomerFormWidget), findsOneWidget);
  });

  testWidgets('finds form new', (tester) async {
    final client = MockClient();
    final customerBloc = CustomerBloc();
    customerBloc.api.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer_id data with 200
    final String response = '{"customer_id":2201,"created":true}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/customer/customer/check_customer_id_handling/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(response, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    CustomerPage widget = CustomerPage(
      bloc: customerBloc,
      initialMode: 'new'
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CustomerListEmptyWidget), findsNothing);
    expect(find.byType(CustomerListErrorWidget), findsNothing);
    expect(find.byType(CustomerListWidget), findsNothing);
    expect(find.byType(CustomerFormWidget), findsOneWidget);
  });

  testWidgets('finds detail', (tester) async {
    final client = MockClient();
    final customerBloc = CustomerBloc();
    customerBloc.api.httpClient = client;
    customerBloc.customerHistoryOrderApi.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/customer/customer/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(customerData, 200));

    // return customer history data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_customer_v2/?customer_id=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(customerOrderHistoryData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    CustomerDetailPage widget = CustomerDetailPage(
        bloc: customerBloc,
        isEngineer: false,
        pk: 1
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CustomerListErrorWidget), findsNothing);
    expect(find.byType(CustomerDetailWidget), findsOneWidget);
  });
}
