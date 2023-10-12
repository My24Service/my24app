import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/customer/models/form_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/customer/blocs/customer_states.dart';
import 'package:my24app/customer/models/models.dart';
import 'http_client.mocks.dart';
import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch customer detail', () async {
    final client = MockClient();
    final CustomerBloc customerBloc = CustomerBloc();
    customerBloc.api.httpClient = client;

    // return token request with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with a 200
    final String customerData = '{"id": 1, "name": "Test name", "address": "Test road 948"}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/customer/customer/1/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(customerData, 200));

    customerBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<CustomerLoadedState>());
        expect(event.props[0], isA<CustomerFormData>());
      })
    );

    expectLater(customerBloc.stream, emits(isA<CustomerLoadedState>()));

    customerBloc.add(
        CustomerEvent(status: CustomerEventStatus.FETCH_DETAIL, pk: 1));
  });

  test('Test fetch all customers', () async {
    final client = MockClient();
    final customerBloc = CustomerBloc();
    customerBloc.api.httpClient = client;

    // return token request with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with a 200
    final String customerData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "name": "Test name", "address": "Test road 948"}]}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/customer/customer/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(customerData, 200));

    customerBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<CustomersLoadedState>());
        expect(event.props[0], isA<Customers>());
      })
    );

    expectLater(customerBloc.stream, emits(isA<CustomersLoadedState>()));

    customerBloc.add(
        CustomerEvent(status: CustomerEventStatus.FETCH_ALL));
  });

  test('Test customer edit', () async {
    final client = MockClient();
    final customerBloc = CustomerBloc();
    customerBloc.api.httpClient = client;

    Customer customer = Customer(
      id: 1,
      customerId: '123465',
      name: 'Test name',
      address: 'Test road 54',
    );

    // return token request with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with a 200
    final String customerData = '{"id": 1, "name": "Test name", "address": "Test road 948"}';
    when(client.patch(Uri.parse('https://demo.my24service-dev.com/api/customer/customer/1/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(customerData, 200));

    Customer newCustomer = await customerBloc.api.update(1, customer);
    expect(newCustomer, isA<Customer>());
  });

  test('Test customer delete', () async {
    final client = MockClient();
    final customerBloc = CustomerBloc();
    customerBloc.api.httpClient = client;

    // return token request with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with a 204
    when(client.delete(Uri.parse('https://demo.my24service-dev.com/api/customer/customer/1/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 204));

    customerBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<CustomerDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(customerBloc.stream, emits(isA<CustomerDeletedState>()));

    customerBloc.add(
        CustomerEvent(status: CustomerEventStatus.DELETE, pk: 1));
  });

  test('Test customer insert', () async {
    final client = MockClient();
    final customerBloc = CustomerBloc();
    customerBloc.api.httpClient = client;

    Customer customer = Customer(
      customerId: '123465',
      name: 'Test name',
      address: 'Test road 54',
    );

    // return token request with a 200
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with a 200
    final String customerData = '{"id": 1, "name": "Test name", "address": "Test road 948"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/customer/customer/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(customerData, 201));

    Customer newCustomer = await customerBloc.api.insert(customer);
    expect(newCustomer, isA<Customer>());
  });
}
