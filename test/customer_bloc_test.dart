import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/customer/blocs/customer_states.dart';
import 'package:my24app/customer/models/models.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch customer detail', () async {
    final client = MockClient();
    final CustomerBloc customerBloc = CustomerBloc(CustomerInitialState());
    customerBloc.localCustomerApi.httpClient = client;
    customerBloc.localCustomerApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with a 200
    final String customerData = '{"id": 1, "name": "Test name", "address": "Test road 948"}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/customer/customer/1/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(customerData, 200));

    customerBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<CustomerLoadedState>());
        expect(event.props[0], isA<Customer>());
      })
    );

    expectLater(customerBloc.stream, emits(isA<CustomerLoadedState>()));

    customerBloc.add(
        CustomerEvent(status: CustomerEventStatus.FETCH_DETAIL, value: 1));
  });

  test('Test fetch all customers', () async {
    final client = MockClient();
    final customerBloc = CustomerBloc(CustomerInitialState());
    customerBloc.localCustomerApi.httpClient = client;
    customerBloc.localCustomerApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with a 200
    final String customerData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "name": "Test name", "address": "Test road 948"}]}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/customer/customer/'), headers: anyNamed('headers')))
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
    final customerBloc = CustomerBloc(CustomerInitialState());
    customerBloc.localCustomerApi.httpClient = client;
    customerBloc.localCustomerApi.localUtils.httpClient = client;

    Customer customer = Customer(
      id: 1,
      customerId: '123465',
      name: 'Test name',
      address: 'Test road 54',
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with a 200
    final String customerData = '{"id": 1, "name": "Test name", "address": "Test road 948"}';
    when(client.put(Uri.parse('https://demo.my24service-dev.com/customer/customer/1/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(customerData, 200));

    customerBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<CustomerEditState>());
        expect(event.props[0], isA<Customer>());
      })
    );

    expectLater(customerBloc.stream, emits(isA<CustomerEditState>()));

    customerBloc.add(
        CustomerEvent(status: CustomerEventStatus.EDIT, value: customer));
  });

  test('Test customer delete', () async {
    final client = MockClient();
    final customerBloc = CustomerBloc(CustomerInitialState());
    customerBloc.localCustomerApi.httpClient = client;
    customerBloc.localCustomerApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with a 204
    when(client.delete(Uri.parse('https://demo.my24service-dev.com/customer/customer/1/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 204));

    customerBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<CustomerDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(customerBloc.stream, emits(isA<CustomerDeletedState>()));

    customerBloc.add(
        CustomerEvent(status: CustomerEventStatus.DELETE, value: 1));
  });

  test('Test customer insert', () async {
    final client = MockClient();
    final customerBloc = CustomerBloc(CustomerInitialState());
    customerBloc.localCustomerApi.httpClient = client;
    customerBloc.localCustomerApi.localUtils.httpClient = client;

    Customer customer = Customer(
      customerId: '123465',
      name: 'Test name',
      address: 'Test road 54',
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return customer data with a 200
    final String customerData = '{"id": 1, "name": "Test name", "address": "Test road 948"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/customer/customer/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(customerData, 201));

    customerBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<CustomerInsertState>());
        expect(event.props[0], isA<Customer>());
      })
    );

    expectLater(customerBloc.stream, emits(isA<CustomerInsertState>()));

    customerBloc.add(
        CustomerEvent(status: CustomerEventStatus.INSERT, value: customer));
  });
}
