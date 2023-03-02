import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/blocs/document_states.dart';
import 'package:my24app/order/models/order/models.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all documents', () async {
    final client = MockClient();
    final documentBlock = DocumentBloc();
    documentBlock.localDocumentApi.httpClient = client;
    documentBlock.localDocumentApi.localUtils.httpClient = client;

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
        expect(event, isA<DocumentsLoadedState>());
        expect(event.props[0], isA<OrderDocuments>());
      })
    );

    expectLater(documentBlock.stream, emits(isA<DocumentsLoadedState>()));

    documentBlock.add(
        DocumentEvent(status: DocumentEventStatus.FETCH_ALL, orderPk: 1));
  });

  test('Test document delete', () async {
    final client = MockClient();
    final documentBlock = DocumentBloc();
    documentBlock.localDocumentApi.httpClient = client;
    documentBlock.localDocumentApi.localUtils.httpClient = client;

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
        expect(event, isA<DocumentDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(documentBlock.stream, emits(isA<DocumentDeletedState>()));

    documentBlock.add(
        DocumentEvent(status: DocumentEventStatus.DELETE, value: 1));
  });

  test('Test document insert', () async {
    final client = MockClient();
    final documentBlock = DocumentBloc();
    documentBlock.localDocumentApi.httpClient = client;
    documentBlock.localDocumentApi.localUtils.httpClient = client;

    OrderDocument document = OrderDocument(
      name: 'test',
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

    final OrderDocument newDocument = await documentBlock.localDocumentApi.insertOrderDocument(document, 1);
    expect(newDocument, isA<OrderDocument>());
  });
}
