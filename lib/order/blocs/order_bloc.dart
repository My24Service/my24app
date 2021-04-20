import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:my24app/order/api/order_api.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/models/models.dart';

enum OrderEventStatus {
  DO_ASYNC,
  DO_SEARCH,
  DO_REFRESH,
  FETCH_ALL,
  FETCH_DETAIL,
  FETCH_UNACCEPTED,
  FETCH_UNASSIGNED,
  FETCH_PAST,
  DELETE,
  EDITED,
  INSERTED,
  ACCEPT,
  ASSIGN
}

class OrderEvent {
  final OrderEventStatus status;
  final dynamic value;
  final int page;
  final String query;

  const OrderEvent({this.value, this.status, this.page, this.query});
}

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderApi localOrderApi = orderApi;
  OrderBloc(OrderState initialState) : super(initialState);

  @override
  Stream<OrderState> mapEventToState(event) async* {
    if (event.status == OrderEventStatus.DO_ASYNC) {
      yield OrderLoadingState();
    }

    if (event.status == OrderEventStatus.DO_SEARCH) {
      yield OrderSearchState();
    }

    if (event.status == OrderEventStatus.DO_REFRESH) {
      yield OrderRefreshState();
    }

    if (event.status == OrderEventStatus.FETCH_DETAIL) {
      try {
        final Order order = await localOrderApi.fetchOrder(event.value);
        yield OrderLoadedState(order: order);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.FETCH_ALL) {
      try {
        final Orders orders = await localOrderApi.fetchOrders(
            query: event.query,
            page: event.page);
        yield OrdersLoadedState(orders: orders, query: event.query);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.FETCH_UNACCEPTED) {
      try {
        final Orders orders = await localOrderApi.fetchUnaccepted(
            page: event.page,
            query: event.query);
        yield OrdersUnacceptedLoadedState(orders: orders, query: event.query);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.FETCH_UNASSIGNED) {
      try {
        final Orders orders = await localOrderApi.fetchOrdersUnAssigned(
            page: event.value,
            query: event.query);
        yield OrdersUnassignedLoadedState(orders: orders, query: event.query);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.FETCH_PAST) {
      try {
        final Orders orders = await localOrderApi.fetchOrdersPast(
            page: event.page,
            query: event.query);
        yield OrdersPastLoadedState(orders: orders, query: event.query);
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

    if (event.status == OrderEventStatus.EDITED) {
      try {
        yield OrderEditedState(order: event.value);
      } catch (e) {
        yield OrderErrorState(message: e.toString());
      }
    }

    if (event.status == OrderEventStatus.INSERTED) {
      try {
        yield OrderInsertedState(order: event.value);
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
