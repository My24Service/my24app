import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/models/models.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all quotations', () async {
    final client = MockClient();
    final quotationBloc = QuotationBloc(QuotationInitialState());
    quotationBloc.localQuotationApi.httpClient = client;
    quotationBloc.localQuotationApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return quotation data with a 200
    final String quotationData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "name": "1020", "description": "test test", "created_by": {}}]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/quotation/quotation/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(quotationData, 200));

    quotationBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<QuotationsLoadedState>());
        expect(event.props[0], isA<Quotations>());
      })
    );

    expectLater(quotationBloc.stream, emits(isA<QuotationsLoadedState>()));

    quotationBloc.add(QuotationEvent(status: QuotationEventStatus.FETCH_ALL));
  });

  test('Test quotation insert', () async {
    final client = MockClient();
    final quotationBloc = QuotationBloc(QuotationInitialState());
    quotationBloc.localQuotationApi.httpClient = client;
    quotationBloc.localQuotationApi.localUtils.httpClient = client;

    Quotation quotation = Quotation(
      quotationName: 'test',
      quotationAddress: 'test 1',
      quotationCity: 'test',
      quotationProducts: []
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return quotation data with a 201
    final String quotationData = '{"id": 1, "name": "1020", "description": "13948"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/quotation/quotation/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(quotationData, 201));

    Quotation newWuotation = await quotationBloc.localQuotationApi.insertQuotation(quotation);
    expect(newWuotation, isA<Quotation>());
  });

  test('Test quotation delete', () async {
    final client = MockClient();
    final quotationBloc = QuotationBloc(QuotationInitialState());
    quotationBloc.localQuotationApi.httpClient = client;
    quotationBloc.localQuotationApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document delete result with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/api/quotation/quotation/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    quotationBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<QuotationDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(quotationBloc.stream, emits(isA<QuotationDeletedState>()));

    quotationBloc.add(
        QuotationEvent(
            status: QuotationEventStatus.DELETE,
            value: 1
        )
    );
  });

  test('Test quotation accept', () async {
    final client = MockClient();
    final quotationBloc = QuotationBloc(QuotationInitialState());
    quotationBloc.localQuotationApi.httpClient = client;
    quotationBloc.localQuotationApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return accept result with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/quotation/quotation/1/set_quotation_accepted/'),
            headers: anyNamed('headers'), body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response('', 200));

    quotationBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<QuotationAcceptedState>());
          expect(event.props[0], true);
        })
    );

    expectLater(quotationBloc.stream, emits(isA<QuotationAcceptedState>()));

    quotationBloc.add(
        QuotationEvent(
            status: QuotationEventStatus.ACCEPT,
            value: 1
        )
    );
  });
}
