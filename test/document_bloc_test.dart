import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/blocs/document_states.dart';
import 'package:my24app/order/models/models.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test fetch all documents', () async {
    final client = MockClient();
    final orderBloc = DocumentBloc(DocumentInitialState());
    orderBloc.localDocumentApi.httpClient = client;
    orderBloc.localDocumentApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 200
    final String documentData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "name": "1020", "description": "test test"}]}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/order/document/?order=1'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(documentData, 200));

    orderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<DocumentsLoadedState>());
        expect(event.props[0], isA<OrderDocuments>());
      })
    );

    expectLater(orderBloc.stream, emits(isA<DocumentsLoadedState>()));

    orderBloc.add(
        DocumentEvent(status: DocumentEventStatus.FETCH_ALL, orderPk: 1));
  });

  test('Test document delete', () async {
    final client = MockClient();
    final orderBloc = DocumentBloc(DocumentInitialState());
    orderBloc.localDocumentApi.httpClient = client;
    orderBloc.localDocumentApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 204
    when(client.delete(Uri.parse('https://demo.my24service-dev.com/order/document/1/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 204));

    orderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<DocumentDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(orderBloc.stream, emits(isA<DocumentDeletedState>()));

    orderBloc.add(
        DocumentEvent(status: DocumentEventStatus.DELETE, value: 1));
  });

  test('Test document insert', () async {
    final client = MockClient();
    final orderBloc = DocumentBloc(DocumentInitialState());
    orderBloc.localDocumentApi.httpClient = client;
    orderBloc.localDocumentApi.localUtils.httpClient = client;

    OrderDocument document = OrderDocument(
      name: 'test',
      description: 'test test',
      file: '132789654',
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    final String documentData = '{"id": 1, "name": "1020", "description": "13948"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/order/document/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(documentData, 201));

    orderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<DocumentInsertedState>());
        expect(event.props[0], isA<OrderDocument>());
      })
    );

    expectLater(orderBloc.stream, emits(isA<DocumentInsertedState>()));

    orderBloc.add(
        DocumentEvent(status: DocumentEventStatus.INSERT, value: document, orderPk: 1));
  });
}
