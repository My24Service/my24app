import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/mobile/pages/customer_history.dart';
import 'package:my24app/mobile/widgets/customer_history/empty.dart';
import 'package:my24app/mobile/widgets/customer_history/error.dart';
import 'package:my24app/mobile/widgets/customer_history/list.dart';
import 'package:my24app/mobile/blocs/customer_history_bloc.dart';
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
    final customerHistoryBloc = CustomerHistoryBloc();

    customerHistoryBloc.api.httpClient = client;
    customerHistoryBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return activity data with a 200
    final String customerHistoryOrderData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$customerHistoryOrder]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_customer_v2/?customer_id=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(customerHistoryOrderData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    CustomerHistoryPage widget = CustomerHistoryPage(
        customerPk: 1,
        bloc: customerHistoryBloc,
        customerName: "test name",
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CustomerHistoryEmptyWidget), findsNothing);
    expect(find.byType(CustomerHistoryErrorWidget), findsNothing);
    expect(find.byType(CustomerHistoryWidget), findsOneWidget);
  });

  testWidgets('finds empty', (tester) async {
    final client = MockClient();
    final customerHistoryBloc = CustomerHistoryBloc();
    customerHistoryBloc.api.httpClient = client;
    customerHistoryBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return activity data with a 200
    final String customerHistoryOrderData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_customer_v2/?customer_id=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(customerHistoryOrderData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    CustomerHistoryPage widget = CustomerHistoryPage(
      customerPk: 1,
      bloc: customerHistoryBloc,
      customerName: "test name",
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CustomerHistoryEmptyWidget), findsOneWidget);
    expect(find.byType(CustomerHistoryErrorWidget), findsNothing);
    expect(find.byType(CustomerHistoryWidget), findsNothing);
  });

  testWidgets('finds error', (tester) async {
    final client = MockClient();
    final customerHistoryBloc = CustomerHistoryBloc();
    customerHistoryBloc.api.httpClient = client;
    customerHistoryBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return activity data with a 500
    final String customerHistoryOrderData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_customer_v2/?customer_id=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(customerHistoryOrderData, 500));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    CustomerHistoryPage widget = CustomerHistoryPage(
      customerPk: 1,
      bloc: customerHistoryBloc,
      customerName: "test name",
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CustomerHistoryEmptyWidget), findsNothing);
    expect(find.byType(CustomerHistoryErrorWidget), findsOneWidget);
    expect(find.byType(CustomerHistoryWidget), findsNothing);
  });

}
