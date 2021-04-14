import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/api/order_api.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/models/models.dart';

enum OrderEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  FETCH_UNACCEPTED,
  FETCH_UNASSIGNED,
  DELETE,
  EDIT,
  INSERT,
  ACCEPT,
  ASSIGN
}

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
    if (event.status == OrderEventStatus.DO_ASYNC) {
      yield OrderLoadingState();
    }

    if (event.status == OrderEventStatus.FETCH_ALL) {
      try {
        final Orders orders = await localOrderApi.fetchOrders(
            query: event.value);
        yield OrdersLoadedState(orders: orders);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.FETCH_DETAIL) {
      try {
        final Order order = await localOrderApi.fetchOrder(event.value);
        yield OrderLoadedState(order: order);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.FETCH_UNACCEPTED) {
      try {
        final Orders orders = await localOrderApi.fetchUnaccepted();
        yield OrdersUnacceptedLoadedState(orders: orders);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.FETCH_UNASSIGNED) {
      try {
        final Orders orders = await localOrderApi.fetchOrdersUnAssigned();
        yield OrdersUnassignedLoadedState(orders: orders);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.DELETE) {
      try {
        final bool result = await localOrderApi.deleteOrder(event.value);
        yield OrderDeletedState(result: result);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.EDIT) {
      try {
        final Order order = await localOrderApi.editOrder(event.value);
        yield OrderEditState(order: order);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.INSERT) {
      try {
        final Order order = await localOrderApi.insertOrder(event.value);
        yield OrderInsertedState(order: order);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.ACCEPT) {
      try {
        final bool result = await localOrderApi.acceptOrder(event.value);
        yield OrderAcceptedState(result: result);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }
  }
}
