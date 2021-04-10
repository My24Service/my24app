import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/models/models.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  test('Test fetch order detail', () async {
    final client = MockClient();

    OrderBloc orderBloc = OrderBloc(OrderInitialState());
    orderBloc.localOrderApi.httpClient = client;
    orderBloc.localOrderApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'), headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    final String orderData = '{"id": 1, "customer_id": "1020", "order_id": "13948", "service_number": "034798"}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/order/order/1/'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(orderData, 200));

    orderBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<OrderLoadedState>());
      })
    );

    expectLater(orderBloc.stream, emits(isA<OrderLoadedState>()));

    orderBloc.add(
        OrderEvent(status: OrderEventStatus.FETCH_DETAIL, value: 1));
  });

  // test('Test fetch all orders', () async {
  //   final orderBloc = OrderBloc(OrderInitialState());

  //   orderBloc.stream.listen(
  //     expectAsync1((event) {
  //       expect(event, isA<OrdersLoadedState>());
  //     })
  //   );

  //   expectLater(orderBloc.stream, emits(isA<OrdersLoadedState>()));

  //   orderBloc.add(
  //       OrderEvent(status: OrderEventStatus.FETCH_ALL));
  // });
}
