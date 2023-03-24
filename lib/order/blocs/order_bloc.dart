import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/order/models/order/api.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/company/api/company_api.dart';
import 'package:my24app/company/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/customer/api/customer_api.dart';
import 'package:my24app/customer/models/models.dart';
import '../models/order/form_data.dart';

enum OrderEventStatus {
  DO_ASYNC,
  DO_SEARCH,
  DO_REFRESH,
  FETCH_ALL,
  FETCH_DETAIL,
  FETCH_DETAIL_VIEW,
  FETCH_UNACCEPTED,
  FETCH_UNASSIGNED,
  FETCH_PAST,
  FETCH_SALES,

  NEW,
  DELETE,
  UPDATE,
  INSERT,
  UPDATE_FORM_DATA,
  ACCEPT,
  REJECT,

  ASSIGN
}

class OrderEvent {
  final OrderEventStatus status;
  final int pk;
  final int page;
  final String query;
  final Order order;
  final OrderFormData formData;

  const OrderEvent({
    this.pk,
    this.status,
    this.page,
    this.query,
    this.order,
    this.formData
  });
}

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderApi api = OrderApi();

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
        await _handleFetchState(event, emit);
      }
      else if (event.status == OrderEventStatus.FETCH_DETAIL_VIEW) {
        await _handleFetchViewState(event, emit);
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

      else if (event.status == OrderEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == OrderEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == OrderEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == OrderEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == OrderEventStatus.NEW) {
        await _handleNewFormDataState(event, emit);
      }
      else if (event.status == OrderEventStatus.ACCEPT) {
        _handleAcceptState(event, emit);
      }
      else if (event.status == OrderEventStatus.REJECT) {
        _handleRejectState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleUpdateFormDataState(OrderEvent event, Emitter<OrderState> emit) {
    emit(OrderLoadedState(formData: event.formData));
  }

  Future<void> _handleNewFormDataState(OrderEvent event, Emitter<OrderState> emit) async {
    final OrderTypes orderTypes = await api.fetchOrderTypes();
    final OrderFormData orderFormData = OrderFormData.createEmpty(orderTypes);

    final String submodel = await utils.getUserSubmodel();
    final bool hasBranches = await utils.getHasBranches();

    if (!hasBranches && submodel == 'customer_user') {
      final Customer customer = await customerApi.fetchCustomerFromPrefs();
      orderFormData.fillFromCustomer(customer);
    } else {
      if (submodel == 'employee_user') {
        final Branch branch = await companyApi.fetchMyBranch();
        orderFormData.fillFromBranch(branch);
      }
    }

    emit(OrderNewState(
        formData: orderFormData
    ));
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

  Future<void> _handleFetchState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final OrderTypes orderTypes = await api.fetchOrderTypes();
      final Order order = await api.detail(event.pk);
      emit(OrderLoadedState(formData: OrderFormData.createFromModel(order, orderTypes)));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchViewState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Order order = await api.detail(event.pk);
      emit(OrderLoadedViewState(order: order));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchAllState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.list(filters: {
        'order_by': '-start_date',
        'query': event.query,
        'page': event.page
      });
      emit(OrdersLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnacceptedState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.fetchUnaccepted(
          page: event.page,
          query: event.query);
      emit(OrdersUnacceptedLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnassignedState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.fetchOrdersUnAssigned(
          page: event.page,
          query: event.query);
      emit(OrdersUnassignedLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchPastState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.fetchOrdersPast(
          page: event.page,
          query: event.query);
      emit(OrdersPastLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchSalesState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Orders orders = await api.fetchSalesOrders(
          page: event.page,
          query: event.query);
      emit(OrdersSalesLoadedState(orders: orders, query: event.query, page: event.page));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Order order = await api.insert(event.order);
      emit(OrderInsertedState(order: order));
    } catch(e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final Order order = await api.update(event.pk, event.order);
      emit(OrderUpdatedState(order: order));
    } catch(e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final bool result = await api.delete(event.pk);
      emit(OrderDeletedState(result: result));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleAcceptState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final bool result = await api.acceptOrder(event.pk);
      emit(OrderAcceptedState(result: result));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleRejectState(OrderEvent event, Emitter<OrderState> emit) async {
    try {
      final bool result = await api.rejectOrder(event.pk);
      emit(OrderRejectedState(result: result));
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }

}
