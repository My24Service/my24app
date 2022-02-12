import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/models/models.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch order detail', () async {
    final client = MockClient();
    final OrderBloc orderBloc = OrderBloc(OrderInitialState());
    orderBloc.localOrderApi.httpClient = client;
    orderBloc.localOrderApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    final String orderData = '{"id": 1, "customer_id": "1020", "order_id": "13948", "service_number": "034798"}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(orderData, 200));

    orderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrderLoadedState>());
        expect(event.props[0], isA<Order>());
      })
    );

    expectLater(orderBloc.stream, emits(isA<OrderLoadedState>()));

    orderBloc.add(
        OrderEvent(status: OrderEventStatus.FETCH_DETAIL, value: 1));
  });

  test('Test fetch all orders', () async {
    final client = MockClient();
    final orderBloc = OrderBloc(OrderInitialState());
    orderBloc.localOrderApi.httpClient = client;
    orderBloc.localOrderApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    final String orderData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "customer_id": "1020", "order_id": "13948", "service_number": "034798"}]}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(orderData, 200));

    orderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrdersLoadedState>());
        expect(event.props[0], isA<Orders>());
      })
    );

    expectLater(orderBloc.stream, emits(isA<OrdersLoadedState>()));

    orderBloc.add(
        OrderEvent(status: OrderEventStatus.FETCH_ALL));
  });

  test('Test order edit', () async {
    final client = MockClient();
    final orderBloc = OrderBloc(OrderInitialState());
    orderBloc.localOrderApi.httpClient = client;
    orderBloc.localOrderApi.localUtils.httpClient = client;

    Order order = Order(
      id: 1,
      customerId: '123465',
      orderId: '987654',
      serviceNumber: '132789654',
      orderLines: [],
      infoLines: []
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    final String orderData = '{"id": 1, "customer_id": "1020", "order_id": "13948", "service_number": "034798"}';
    when(client.put(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(orderData, 200));

    orderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrderEditedState>());
        expect(event.props[0], isA<Order>());
      })
    );

    expectLater(orderBloc.stream, emits(isA<OrderEditedState>()));

    orderBloc.add(
        OrderEvent(status: OrderEventStatus.EDITED, value: order));
  });

  test('Test order delete', () async {
    final client = MockClient();
    final orderBloc = OrderBloc(OrderInitialState());
    orderBloc.localOrderApi.httpClient = client;
    orderBloc.localOrderApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 204
    when(client.delete(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 204));

    orderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrderDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(orderBloc.stream, emits(isA<OrderDeletedState>()));

    orderBloc.add(
        OrderEvent(status: OrderEventStatus.DELETE, value: 1));
  });

  test('Test order insert', () async {
    final client = MockClient();
    final orderBloc = OrderBloc(OrderInitialState());
    orderBloc.localOrderApi.httpClient = client;
    orderBloc.localOrderApi.localUtils.httpClient = client;

    Order order = Order(
      customerId: '123465',
      orderId: '987654',
      serviceNumber: '132789654',
      orderLines: [],
      infoLines: []
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    final String orderData = '{"id": 1, "customer_id": "1020", "order_id": "13948", "service_number": "034798"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/order/order/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(orderData, 201));

    Order newOrder = await orderBloc.localOrderApi.insertOrder(order);
    expect(newOrder, isA<Order>());
  });

  test('Test fetch processing', () async {
    final client = MockClient();
    final orderBloc = OrderBloc(OrderInitialState());
    orderBloc.localOrderApi.httpClient = client;
    orderBloc.localOrderApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    final String orderData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "customer_id": "1020", "order_id": "13948", "service_number": "034798"}]}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_customer_not_accepted/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(orderData, 200));

    orderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrdersUnacceptedLoadedState>());
        expect(event.props[0], isA<Orders>());
      })
    );

    expectLater(orderBloc.stream, emits(isA<OrdersUnacceptedLoadedState>()));

    orderBloc.add(
        OrderEvent(status: OrderEventStatus.FETCH_UNACCEPTED));
  });

  test('Test accept order', () async {
    final client = MockClient();
    final orderBloc = OrderBloc(OrderInitialState());
    orderBloc.localOrderApi.httpClient = client;
    orderBloc.localOrderApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return result with a 200
    final String orderData = '{}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/set_order_accepted/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(orderData, 200));

    orderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrderAcceptedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(orderBloc.stream, emits(isA<OrderAcceptedState>()));

    orderBloc.add(
        OrderEvent(status: OrderEventStatus.ACCEPT, value: 1));
  });

  test('Test fetch all unassigned orders', () async {
    final client = MockClient();
    final orderBloc = OrderBloc(OrderInitialState());
    orderBloc.localOrderApi.httpClient = client;
    orderBloc.localOrderApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    final String orderData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "customer_id": "1020", "order_id": "13948", "service_number": "034798"}]}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/dispatch_list_unassigned/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(orderData, 200));

    orderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrdersUnassignedLoadedState>());
        expect(event.props[0], isA<Orders>());
      })
    );

    expectLater(orderBloc.stream, emits(isA<OrdersUnassignedLoadedState>()));

    orderBloc.add(
        OrderEvent(status: OrderEventStatus.FETCH_UNASSIGNED));
  });

}
