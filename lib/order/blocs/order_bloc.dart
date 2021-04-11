import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/order/api/order_api.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/models/models.dart';

enum OrderEventStatus { FETCH_ALL, FETCH_DETAIL, DELETE, EDIT }

class OrderEvent {
  final OrderEventStatus status;
  final dynamic value;

  const OrderEvent({this.value, this.status});
}

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderApi localOrderApi = orderApi;
  OrderBloc(OrderState initialState) : super(initialState);

  @override
  Stream<OrderState> mapEventToState(event) async* {
    if (event.status == OrderEventStatus.FETCH_ALL) {
      try {
        final Orders orders = await localOrderApi.fetchOrders(query: event.value);
        yield OrdersLoadedState(orders: orders);
      } catch(e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.FETCH_DETAIL) {
      try {
        final Order order = await localOrderApi.fetchOrder(event.value);
        yield OrderLoadedState(order: order);
      } catch(e) {
        yield OrderErrorState(message: e.toString());
      }
    }
//
    if (event.status == OrderEventStatus.DELETE) {
      try {
        final bool result = await localOrderApi.deleteOrder(event.value);
        yield OrderDeletedState(result: result);
      } catch(e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.EDIT) {
      try {
        final Order order = await localOrderApi.editOrder(event.value);
        yield OrderEditState(order: order);
      } catch(e) {
        yield OrderErrorState(message: e.toString());
      }
    }
  }
}
