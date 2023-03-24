import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/order/models/document/models.dart';
import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/blocs/document_states.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all documents', () async {
    final client = MockClient();
    final documentBlock = OrderDocumentBloc();
    documentBlock.api.httpClient = client;
    documentBlock.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 200
    final String documentData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "name": "1020", "description": "test test"}]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/document/?order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(documentData, 200));

    documentBlock.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrderDocumentsLoadedState>());
        expect(event.props[0], isA<OrderDocuments>());
      })
    );

    expectLater(documentBlock.stream, emits(isA<OrderDocumentsLoadedState>()));

    documentBlock.add(
        OrderDocumentEvent(status: OrderDocumentEventStatus.FETCH_ALL, orderId: 1));
  });

  test('Test document delete', () async {
    final client = MockClient();
    final documentBlock = OrderDocumentBloc();
    documentBlock.api.httpClient = client;
    documentBlock.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/api/order/document/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    documentBlock.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrderDocumentDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(documentBlock.stream, emits(isA<OrderDocumentDeletedState>()));

    documentBlock.add(
        OrderDocumentEvent(status: OrderDocumentEventStatus.DELETE, pk: 1));
  });

  test('Test document insert', () async {
    final client = MockClient();
    final documentBlock = OrderDocumentBloc();
    documentBlock.api.httpClient = client;
    documentBlock.api.localUtils.httpClient = client;

    OrderDocument document = OrderDocument(
      name: 'test',
      orderId: 1,
      description: 'test test',
      file: '132789654',
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 201
    final String documentData = '{"id": 1, "name": "1020", "description": "13948"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/order/document/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(documentData, 201));

    final OrderDocument newDocument = await documentBlock.api.insert(document);
    expect(newDocument, isA<OrderDocument>());
  });
}
