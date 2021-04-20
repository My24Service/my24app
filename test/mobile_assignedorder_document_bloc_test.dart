import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/mobile/blocs/document_bloc.dart';
import 'package:my24app/mobile/blocs/document_states.dart';
import 'package:my24app/mobile/models/models.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all documents for an assigned order', () async {
    final client = MockClient();
    final documentBloc = DocumentBloc(DocumentInitialState());
    documentBloc.localMobileApi.httpClient = client;
    documentBloc.localMobileApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 200
    final String documentData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "name": "1020", "description": "test test"}]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/mobile/assignedorderdocument/?assigned_order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(documentData, 200));

    documentBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<DocumentsLoadedState>());
        expect(event.props[0], isA<AssignedOrderDocuments>());
      })
    );

    expectLater(documentBloc.stream, emits(isA<DocumentsLoadedState>()));

    documentBloc.add(
        DocumentEvent(
            status: DocumentEventStatus.FETCH_ALL,
            value: 1
        )
    );
  });

  test('Test document insert', () async {
    final client = MockClient();
    final documentBloc = DocumentBloc(DocumentInitialState());
    documentBloc.localMobileApi.httpClient = client;
    documentBloc.localMobileApi.localUtils.httpClient = client;

    AssignedOrderDocument document = AssignedOrderDocument(
      name: 'test',
      description: 'test test',
      document: '132789654',
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document data with a 200
    final String documentData = '{"id": 1, "name": "1020", "description": "13948"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/mobile/assignedorderdocument/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(documentData, 201));

    documentBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<DocumentInsertedState>());
          expect(event.props[0], isA<AssignedOrderDocument>());
        })
    );

    expectLater(documentBloc.stream, emits(isA<DocumentInsertedState>()));

    documentBloc.add(
        DocumentEvent(
            status: DocumentEventStatus.INSERT,
            document: document,
            value: 1
        )
    );
  });

  test('Test document delete', () async {
    final client = MockClient();
    final documentBloc = DocumentBloc(DocumentInitialState());
    documentBloc.localMobileApi.httpClient = client;
    documentBloc.localMobileApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document delete result with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/mobile/assignedorderdocument/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    documentBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<DocumentDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(documentBloc.stream, emits(isA<DocumentDeletedState>()));

    documentBloc.add(
        DocumentEvent(
            status: DocumentEventStatus.DELETE,
            value: 1
        )
    );
  });

}
