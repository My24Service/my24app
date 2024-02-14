import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/inventory/blocs/location_inventory_bloc.dart';
import 'package:my24app/inventory/pages/location_inventory.dart';
import 'package:my24app/inventory/widgets/location_inventory/error.dart';
import 'package:my24app/inventory/widgets/location_inventory/main.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  testWidgets('loads main', (tester) async {
    final client = MockClient();
    final inventoryBloc = LocationInventoryBloc();
    inventoryBloc.api.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return locations data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/stock-location/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsData, 200));

    // return location inventory data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/inventory-materials-for-location/?location=2&q='),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsInventoryData, 200));

    LocationInventoryPage widget = LocationInventoryPage(bloc: inventoryBloc);
    widget.inventoryApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(LocationInventoryListErrorWidget), findsNothing);
    expect(find.byType(LocationInventoryWidget), findsOneWidget);
  });

  testWidgets('finds error', (tester) async {
    final client = MockClient();
    final inventoryBloc = LocationInventoryBloc();
    inventoryBloc.api.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return locations data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/stock-location/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsData, 200));

    // return location inventory data with a 500
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/inventory-materials-for-location/?location=2&q='),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsInventoryData, 500));

    LocationInventoryPage widget = LocationInventoryPage(bloc: inventoryBloc);
    widget.inventoryApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(LocationInventoryListErrorWidget), findsOneWidget);
    expect(find.byType(LocationInventoryWidget), findsNothing);
  });
}
