import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/customer/models/api.dart';
import 'package:my24app/customer/blocs/customer_states.dart';
import 'package:my24app/customer/models/models.dart';

import '../../order/models/order/api.dart';
import '../../order/models/order/models.dart';
import '../models/form_data.dart';

enum CustomerEventStatus {
  FETCH_ALL,
  FETCH_DETAIL,
  FETCH_DETAIL_VIEW,
  DO_ASYNC,
  DO_REFRESH,
  DO_SEARCH,
  DELETE,
  UPDATE,
  INSERT,
  NEW,
  NEW_EMPTY,
  UPDATE_FORM_DATA
}

class CustomerEvent {
  final CustomerEventStatus status;
  final int pk;
  final int page;
  final String query;
  final Customer customer;
  final CustomerFormData formData;

  const CustomerEvent({
    this.status,
    this.pk,
    this.page,
    this.query,
    this.customer,
    this.formData
  });
}

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  CustomerApi api = CustomerApi();
  CustomerHistoryOrderApi customerHistoryOrderApi = CustomerHistoryOrderApi();

  CustomerBloc() : super(CustomerInitialState()) {
    on<CustomerEvent>((event, emit) async {
      if (event.status == CustomerEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == CustomerEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == CustomerEventStatus.DO_REFRESH) {
        _handleDoRefreshState(event, emit);
      }
      else if (event.status == CustomerEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == CustomerEventStatus.FETCH_DETAIL) {
        await _handleFetchDetailState(event, emit);
      }
      else if (event.status == CustomerEventStatus.FETCH_DETAIL_VIEW) {
        await _handleFetchDetailViewState(event, emit);
      }
      else if (event.status == CustomerEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == CustomerEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == CustomerEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == CustomerEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == CustomerEventStatus.NEW) {
        await _handleNewFormDataState(event, emit);
      }
      else if (event.status == CustomerEventStatus.NEW_EMPTY) {
        await _handleNewEmptyFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(CustomerEvent event, Emitter<CustomerState> emit) {
    emit(CustomerLoadingState());
  }

  void _handleDoSearchState(CustomerEvent event, Emitter<CustomerState> emit) {
    emit(CustomerSearchState());
  }

  void _handleDoRefreshState(CustomerEvent event, Emitter<CustomerState> emit) {
    emit(CustomerRefreshState());
  }

  Future<void> _handleNewFormDataState(CustomerEvent event, Emitter<CustomerState> emit) async {
    String customerId = await api.fetchNewCustomerId();

    emit(CustomerNewState(
        fromEmpty: false,
        formData: CustomerFormData.createEmpty(customerId)
    ));
  }

  Future<void> _handleNewEmptyFormDataState(CustomerEvent event, Emitter<CustomerState> emit) async {
    String customerId = await api.fetchNewCustomerId();

    emit(CustomerNewState(
        fromEmpty: true,
        formData: CustomerFormData.createEmpty(customerId)
    ));
  }

  void _handleUpdateFormDataState(CustomerEvent event, Emitter<CustomerState> emit) {
    emit(CustomerLoadedState(formData: event.formData));
  }

  Future<void> _handleFetchAllState(CustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final Customers customers = await api.list(
          filters: {
            'query': event.query,
            'page': event.page
          });
      emit(CustomersLoadedState(
          customers: customers,
          query: event.query
      ));
    } catch(e) {
      emit(CustomerErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailState(CustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final Customer customer = await api.detail(event.pk);
      emit(CustomerLoadedState(formData: CustomerFormData.createFromModel(customer)));
    } catch(e) {
      emit(CustomerErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailViewState(CustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final Customer customer = await api.detail(event.pk);
      final CustomerHistoryOrders customerHistoryOrders = await customerHistoryOrderApi.list(
          filters: {
            "customer_id": event.pk,
            'query': event.query,
            'page': event.page
          });

      emit(CustomerLoadedViewState(
          customer: customer,
          customerHistoryOrders: customerHistoryOrders,
          query: event.query,
          page: event.page
      ));
    } catch(e) {
      emit(CustomerErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(CustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final Customer customer = await api.insert(event.customer);
      emit(CustomerInsertedState(customer: customer));
    } catch(e) {
      emit(CustomerErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(CustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final Customer customer = await api.update(event.pk, event.customer);
      emit(CustomerUpdatedState(customer: customer));
    } catch(e) {
      emit(CustomerErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(CustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final bool result = await api.delete(event.pk);
      emit(CustomerDeletedState(result: result));
    } catch(e) {
      print(e);
      emit(CustomerErrorState(message: e.toString()));
    }
  }
}
