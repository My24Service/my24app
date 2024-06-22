import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/mobile/pages/document.dart';
import 'package:my24app/mobile/widgets/document/form.dart';
import 'package:my24app/mobile/widgets/document/error.dart';
import 'package:my24app/mobile/widgets/document/list.dart';
import 'package:my24app/mobile/blocs/document_bloc.dart';
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
    final documentBloc = DocumentBloc();
    documentBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 200
    final String documentData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": [$assignedOrderDocument]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderdocument/?assigned_order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(documentData, 200));

    DocumentPage widget = DocumentPage(assignedOrderId: 1, bloc: documentBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(DocumentFormWidget), findsNothing);
    expect(find.byType(DocumentListErrorWidget), findsNothing);
    expect(find.byType(DocumentListWidget), findsOneWidget);
  });

  testWidgets('finds empty', (tester) async {
    final client = MockClient();
    final documentBloc = DocumentBloc();
    documentBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 200
    final String documentData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderdocument/?assigned_order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(documentData, 200));

    DocumentPage widget = DocumentPage(assignedOrderId: 1, bloc: documentBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(DocumentFormWidget), findsOneWidget);
    expect(find.byType(DocumentListErrorWidget), findsNothing);
    expect(find.byType(DocumentListWidget), findsNothing);
  });

  testWidgets('finds error', (tester) async {
    final client = MockClient();
    final documentBloc = DocumentBloc();
    documentBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 500
    final String documentData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderdocument/?assigned_order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(documentData, 500));

    DocumentPage widget = DocumentPage(assignedOrderId: 1, bloc: documentBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(DocumentFormWidget), findsNothing);
    expect(find.byType(DocumentListErrorWidget), findsOneWidget);
    expect(find.byType(DocumentListWidget), findsNothing);
  });

  testWidgets('finds form edit', (tester) async {
    final client = MockClient();
    final documentBloc = DocumentBloc();
    documentBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedorderdocument/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(assignedOrderDocument, 200));

    DocumentPage widget = DocumentPage(
      assignedOrderId: 1, bloc: documentBloc,
      initialMode: 'form',
      pk: 1,
    );
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(DocumentListErrorWidget), findsNothing);
    expect(find.byType(DocumentListWidget), findsNothing);
    expect(find.byType(DocumentFormWidget), findsOneWidget);
  });

  testWidgets('finds form new', (tester) async {
    final client = MockClient();
    final documentBloc = DocumentBloc();
    documentBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    DocumentPage widget = DocumentPage(
      assignedOrderId: 1, bloc: documentBloc,
      initialMode: 'new'
    );
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(DocumentListErrorWidget), findsNothing);
    expect(find.byType(DocumentListWidget), findsNothing);
    expect(find.byType(DocumentFormWidget), findsOneWidget);
  });
}
