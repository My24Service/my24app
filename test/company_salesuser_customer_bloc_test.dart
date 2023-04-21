import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/company/models/salesuser_customer/form_data.dart';
import 'package:my24app/company/models/salesuser_customer/models.dart';
import 'package:my24app/company/blocs/salesuser_customer_bloc.dart';
import 'package:my24app/company/blocs/salesuser_customer_states.dart';

import 'fixtures.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all customers', () async {
    final client = MockClient();
    final salesUserCustomerBloc = SalesUserCustomerBloc();
    salesUserCustomerBloc.api.httpClient = client;
    salesUserCustomerBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with a 200
    final String salesUserCustomersData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$salesUserCustomerData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/salesusercustomer/my/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(salesUserCustomersData, 200));

    salesUserCustomerBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<SalesUserCustomersLoadedState>());
        expect(event.props[0], isA<SalesUserCustomers>());
      })
    );

    expectLater(salesUserCustomerBloc.stream, emits(isA<SalesUserCustomersLoadedState>()));

    salesUserCustomerBloc.add(
        SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.FETCH_ALL));
  });

  test('Test customer delete', () async {
    final client = MockClient();
    final salesUserCustomerBloc = SalesUserCustomerBloc();
    salesUserCustomerBloc.api.httpClient = client;
    salesUserCustomerBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return no content with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/api/company/salesusercustomer/my/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    salesUserCustomerBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<SalesUserCustomerDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(salesUserCustomerBloc.stream, emits(isA<SalesUserCustomerDeletedState>()));

    salesUserCustomerBloc.add(
        SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DELETE, pk: 1));
  });

  test('Test customer insert', () async {
    final client = MockClient();
    final salesUserCustomerBloc = SalesUserCustomerBloc();
    salesUserCustomerBloc.api.httpClient = client;
    salesUserCustomerBloc.api.localUtils.httpClient = client;

    SalesUserCustomer salesUserCustomer = SalesUserCustomer(
      customer: 1,
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return salesUserCustomer data with a 201
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/company/salesusercustomer/my/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(salesUserCustomerData, 201));

    final SalesUserCustomer newSalesUserCustomer = await salesUserCustomerBloc.api.insert(salesUserCustomer);
    expect(newSalesUserCustomer, isA<SalesUserCustomer>());
  });
}
