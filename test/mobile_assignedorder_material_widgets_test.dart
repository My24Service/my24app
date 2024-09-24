import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/mobile/pages/material.dart';
import 'package:my24app/mobile/widgets/material/form.dart';
import 'package:my24app/mobile/widgets/material/error.dart';
import 'package:my24app/mobile/widgets/material/list.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'fixtures.dart';

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
    final materialBloc = AssignedOrderMaterialBloc();
    materialBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return material data with a 200
    final String materialData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": [$assignedOrderMaterial]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedordermaterial/?assigned_order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(materialData, 200));

    // return locations data with a 200
    final String locationsData = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/stock-location/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsData, 200));

    // return user info data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(engineerUser, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    AssignedOrderMaterialPage widget = AssignedOrderMaterialPage(assignedOrderId: 1, bloc: materialBloc);
    widget.utils.httpClient = client;
    widget.locationApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(MaterialFormWidget), findsNothing);
    expect(find.byType(MaterialListErrorWidget), findsNothing);
    expect(find.byType(MaterialListWidget), findsOneWidget);
  });

  testWidgets('finds empty', (tester) async {
    final client = MockClient();
    final materialBloc = AssignedOrderMaterialBloc();
    materialBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return material data with a 200
    final String materialData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedordermaterial/?assigned_order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(materialData, 200));

    // return locations data with a 200
    final String locationsData = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/stock-location/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsData, 200));

    // return user info data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(engineerUser, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    AssignedOrderMaterialPage widget = AssignedOrderMaterialPage(assignedOrderId: 1, bloc: materialBloc);
    widget.utils.httpClient = client;
    widget.locationApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(MaterialFormWidget), findsOneWidget);
    expect(find.byType(MaterialListErrorWidget), findsNothing);
    expect(find.byType(MaterialListWidget), findsNothing);
  });

  testWidgets('finds error', (tester) async {
    final client = MockClient();
    final materialBloc = AssignedOrderMaterialBloc();
    materialBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return material data with a 500
    final String materialData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedordermaterial/?assigned_order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(materialData, 500));

    // return locations data with a 200
    final String locationsData = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/stock-location/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsData, 200));

    // return user info data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(engineerUser, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    AssignedOrderMaterialPage widget = AssignedOrderMaterialPage(assignedOrderId: 1, bloc: materialBloc);
    widget.utils.httpClient = client;
    widget.locationApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(MaterialFormWidget), findsNothing);
    expect(find.byType(MaterialListErrorWidget), findsOneWidget);
    expect(find.byType(MaterialListWidget), findsNothing);
  });

  testWidgets('finds form edit', (tester) async {
    final client = MockClient();
    final materialBloc = AssignedOrderMaterialBloc();
    materialBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return material data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedordermaterial/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(assignedOrderMaterial, 200));

    // return locations data with a 200
    final String locationsData = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/stock-location/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsData, 200));

    // return user info data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(engineerUser, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    AssignedOrderMaterialPage widget = AssignedOrderMaterialPage(
      assignedOrderId: 1, bloc: materialBloc,
      initialMode: 'form',
      pk: 1,
    );
    widget.utils.httpClient = client;
    widget.locationApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(MaterialListErrorWidget), findsNothing);
    expect(find.byType(MaterialListWidget), findsNothing);
    expect(find.byType(MaterialFormWidget), findsOneWidget);
  });

  testWidgets('finds form new', (tester) async {
    final client = MockClient();
    final materialBloc = AssignedOrderMaterialBloc();
    materialBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return locations data with a 200
    final String locationsData = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/stock-location/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsData, 200));

    // return user info data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(engineerUser, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    AssignedOrderMaterialPage widget = AssignedOrderMaterialPage(
      assignedOrderId: 1, bloc: materialBloc,
      initialMode: 'new'
    );
    widget.utils.httpClient = client;
    widget.locationApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(MaterialListErrorWidget), findsNothing);
    expect(find.byType(MaterialListWidget), findsNothing);
    expect(find.byType(MaterialFormQuotationMaterialsWidget), findsNothing);
    expect(find.byType(MaterialFormWidget), findsOneWidget);
  });

  testWidgets('finds form new with quotation, all form items', (tester) async {
    final client = MockClient();
    final materialBloc = AssignedOrderMaterialBloc();
    materialBloc.api.httpClient = client;
    materialBloc.quotationApi.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return locations data with a 200
    final String locationsData = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/stock-location/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsData, 200));

    // return user info data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(engineerUser, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    // return quotation materials
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/quotation/quotation/1/get_materials_for_app/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(quotationMaterials, 200));

    // return entered quotation materials
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedordermaterial/quotation/?quotation=1'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response('[]', 200));

    AssignedOrderMaterialPage widget = AssignedOrderMaterialPage(
        assignedOrderId: 1, bloc: materialBloc,
        initialMode: 'new',
        quotationId: 1,
    );
    widget.utils.httpClient = client;
    widget.locationApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(MaterialListErrorWidget), findsNothing);
    expect(find.byType(MaterialListWidget), findsNothing);
    expect(find.byType(MaterialFormWidget), findsOneWidget);
    expect(find.byType(MaterialFormQuotationMaterialsWidget), findsOneWidget);
    // expect(find.byType(DataTable), findsExactly(1));
    // expect(find.byKey(const Key("form-data-column-outer")), findsExactly(1));
    // expect(find.byKey(const Key("form-data-column-0")), findsExactly(1));
    // expect(find.byKey(const Key("form-data-column-1")), findsExactly(1));
    // expect(find.byKey(const Key("form-data-column-2")), findsExactly(0));
  });

  testWidgets('finds form new with quotation, no form items', (tester) async {
    final client = MockClient();
    final materialBloc = AssignedOrderMaterialBloc();
    materialBloc.api.httpClient = client;
    materialBloc.quotationApi.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return locations data with a 200
    final String locationsData = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/stock-location/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsData, 200));

    // return user info data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(engineerUser, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    // return quotation materials
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/quotation/quotation/1/get_materials_for_app/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(quotationMaterials, 200));

    // return entered quotation material
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedordermaterial/quotation/?quotation=1'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(enteredMaterialsFromQuotationAll, 200));

    AssignedOrderMaterialPage widget = AssignedOrderMaterialPage(
      assignedOrderId: 1, bloc: materialBloc,
      initialMode: 'new',
      quotationId: 1,
    );
    widget.utils.httpClient = client;
    widget.locationApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(MaterialListErrorWidget), findsNothing);
    expect(find.byType(MaterialListWidget), findsNothing);
    expect(find.byType(MaterialFormWidget), findsOneWidget);
    expect(find.byType(MaterialFormQuotationMaterialsWidget), findsOneWidget);
    // expect(find.byType(DataTable), findsExactly(1));
    // expect(find.byKey(const Key("form-data-column-outer")), findsExactly(0));
    // expect(find.byKey(const Key("form-data-column-0")), findsExactly(0));
    // expect(find.byKey(const Key("form-data-column-1")), findsExactly(0));
  });

  testWidgets('finds form new with quotation, one form item', (tester) async {
    final client = MockClient();
    final materialBloc = AssignedOrderMaterialBloc();
    materialBloc.api.httpClient = client;
    materialBloc.quotationApi.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return locations data with a 200
    final String locationsData = '{"next": null, "previous": null, "count": 0, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/inventory/stock-location/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(locationsData, 200));

    // return user info data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(engineerUser, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    // return quotation materials
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/quotation/quotation/1/get_materials_for_app/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(quotationMaterials, 200));

    // return entered quotation material
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedordermaterial/quotation/?quotation=1'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(enteredMaterialsFromQuotationOne, 200));

    AssignedOrderMaterialPage widget = AssignedOrderMaterialPage(
      assignedOrderId: 1, bloc: materialBloc,
      initialMode: 'new',
      quotationId: 1,
    );
    widget.utils.httpClient = client;
    widget.locationApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(MaterialListErrorWidget), findsNothing);
    expect(find.byType(MaterialListWidget), findsNothing);
    expect(find.byType(MaterialFormWidget), findsOneWidget);
    expect(find.byType(MaterialFormQuotationMaterialsWidget), findsOneWidget);
    // expect(find.byType(DataTable), findsExactly(1));
    // expect(find.byKey(const Key("form-data-column-outer")), findsExactly(1));
    // expect(find.byKey(const Key("form-data-column-0")), findsExactly(1));
    // expect(find.byKey(const Key("form-data-column-1")), findsExactly(0));
  });
}
