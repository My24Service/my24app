import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

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
  FETCH_SALES,
  DELETE,
  EDITED,
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

  OrderBloc() : super(OrderInitialState()) {
    on<OrderEvent>((event, emit) async {
      if (event.status == OrderEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == OrderEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == OrderEventStatus.DO_REFRESH) {
        _handleDoRefreshState(event, emit);
      }
      else if (event.status == OrderEventStatus.FETCH_DETAIL) {
        await _handleFetchDetailState(event, emit);
      }
      else if (event.status == OrderEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == OrderEventStatus.FETCH_UNACCEPTED) {
        await _handleFetchUnacceptedState(event, emit);
      }
      if (event.status == OrderEventStatus.FETCH_UNASSIGNED) {
        await _handleFetchUnassignedState(event, emit);
      }
      else if (event.status == OrderEventStatus.FETCH_PAST) {
        await _handleFetchPastState(event, emit);
      }
      else if (event.status == OrderEventStatus.FETCH_SALES) {
        await _handleFetchSalesState(event, emit);
      }
      else if (event.status == OrderEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == OrderEventStatus.EDITED) {
        _handleEditedState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(OrderEvent event, Emitter<OrderState> emit) {
    emit(OrderLoadingState());
  }

  void _handleDoSearchState(OrderEvent event, Emitter<OrderState> emit) {
    emit(OrderSearchState());
  }

  void _handleDoRefreshState(OrderEvent event, Emitter<OrderState> emit) {
    emit(OrderRefreshState());
  }

  Future<void> _handleFetchDetailState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Order order = await localOrderApi.fetchOrder(event.value);
      emit(OrderLoadedState(order: order));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchAllState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await localOrderApi.fetchOrders(
          query: event.query,
          page: event.page);
      emit(OrdersLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnacceptedState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await localOrderApi.fetchUnaccepted(
          page: event.page,
          query: event.query);
      emit(OrdersUnacceptedLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnassignedState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await localOrderApi.fetchOrdersUnAssigned(
          page: event.value,
          query: event.query);
      emit(OrdersUnassignedLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchPastState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await localOrderApi.fetchOrdersPast(
          page: event.page,
          query: event.query);
      emit(OrdersPastLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchSalesState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await localOrderApi.fetchSalesOrders(
          page: event.page,
          query: event.query);
      emit(OrdersSalesLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final bool result = await localOrderApi.deleteOrder(event.value);
      emit(OrderDeletedState(result: result));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  void _handleEditedState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      emit(OrderEditedState(order: event.value));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }
}
