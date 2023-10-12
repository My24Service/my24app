import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/company/pages/salesuser_customer.dart';
import 'package:my24app/company/widgets/salesuser_customer/error.dart';
import 'package:my24app/company/widgets/salesuser_customer/list.dart';
import 'package:my24app/company/blocs/salesuser_customer_bloc.dart';
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

  testWidgets('finds list', (tester) async {
    final client = MockClient();
    final salesUserCustomerBloc = SalesUserCustomerBloc();
    salesUserCustomerBloc.api.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return project data with a 200
    final String salesUserCustomersData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$salesUserCustomerData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/salesusercustomer/my/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(salesUserCustomersData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    SalesUserCustomerPage widget = SalesUserCustomerPage(bloc: salesUserCustomerBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(SalesUserCustomerListErrorWidget), findsNothing);
    expect(find.byType(SalesUserCustomerListWidget), findsOneWidget);
  });

  testWidgets('finds error', (tester) async {
    final client = MockClient();
    final salesUserCustomerBloc = SalesUserCustomerBloc();
    salesUserCustomerBloc.api.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return project data with a 500
    final String projectsData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/salesusercustomer/my/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(projectsData, 500));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    SalesUserCustomerPage widget = SalesUserCustomerPage(bloc: salesUserCustomerBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(SalesUserCustomerListErrorWidget), findsOneWidget);
    expect(find.byType(SalesUserCustomerListWidget), findsNothing);
  });
}
