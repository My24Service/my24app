import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/widgets/document/form.dart';
import 'package:my24app/order/widgets/document/empty.dart';
import 'package:my24app/order/widgets/document/error.dart';
import 'package:my24app/order/widgets/document/list.dart';
import 'package:my24app/order/blocs/document_bloc.dart';
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
    final documentBloc = OrderDocumentBloc();

    documentBloc.api.httpClient = client;
    documentBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 200
    final String documentData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": [$orderDocument]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/document/?order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(documentData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    OrderDocumentsPage widget = OrderDocumentsPage(orderId: 1, bloc: documentBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderDocumentListEmptyWidget), findsNothing);
    expect(find.byType(OrderDocumentListErrorWidget), findsNothing);
    expect(find.byType(OrderDocumentListWidget), findsOneWidget);
  });

  testWidgets('finds empty', (tester) async {
    final client = MockClient();
    final documentBloc = OrderDocumentBloc();
    documentBloc.api.httpClient = client;
    documentBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 200
    final String documentData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/document/?order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(documentData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    OrderDocumentsPage widget = OrderDocumentsPage(orderId: 1, bloc: documentBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderDocumentListEmptyWidget), findsOneWidget);
    expect(find.byType(OrderDocumentListErrorWidget), findsNothing);
    expect(find.byType(OrderDocumentListWidget), findsNothing);
  });

  testWidgets('finds error', (tester) async {
    final client = MockClient();
    final documentBloc = OrderDocumentBloc();
    documentBloc.api.httpClient = client;
    documentBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 500
    final String documentData = '{"next": null, "previous": null, "count": 0, "num_pages": 0, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/document/?order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(documentData, 500));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    OrderDocumentsPage widget = OrderDocumentsPage(orderId: 1, bloc: documentBloc);
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderDocumentListEmptyWidget), findsNothing);
    expect(find.byType(OrderDocumentListErrorWidget), findsOneWidget);
    expect(find.byType(OrderDocumentListWidget), findsNothing);
  });

  testWidgets('finds form edit', (tester) async {
    final client = MockClient();
    final documentBloc = OrderDocumentBloc();
    documentBloc.api.httpClient = client;
    documentBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/document/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(orderDocument, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    OrderDocumentsPage widget = OrderDocumentsPage(
      orderId: 1, bloc: documentBloc,
      initialMode: 'form',
      pk: 1,
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderDocumentListEmptyWidget), findsNothing);
    expect(find.byType(OrderDocumentListErrorWidget), findsNothing);
    expect(find.byType(OrderDocumentListWidget), findsNothing);
    expect(find.byType(OrderDocumentFormWidget), findsOneWidget);
  });

  testWidgets('finds form new', (tester) async {
    final client = MockClient();
    final documentBloc = OrderDocumentBloc();
    documentBloc.api.httpClient = client;
    documentBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return member picture data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/public-pictures/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(memberPictures, 200));

    OrderDocumentsPage widget = OrderDocumentsPage(
      orderId: 1, bloc: documentBloc,
      initialMode: 'new'
    );
    widget.utils.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(OrderDocumentListEmptyWidget), findsNothing);
    expect(find.byType(OrderDocumentListErrorWidget), findsNothing);
    expect(find.byType(OrderDocumentListWidget), findsNothing);
    expect(find.byType(OrderDocumentFormWidget), findsOneWidget);
  });
}
