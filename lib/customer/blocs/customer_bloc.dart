import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/customer/api/customer_api.dart';
import 'package:my24app/customer/blocs/customer_states.dart';
import 'package:my24app/customer/models/models.dart';

enum CustomerEventStatus {
  FETCH_ALL,
  FETCH_DETAIL,
  DO_ASYNC,
  DO_REFRESH,
  DO_SEARCH,
  DELETE,
  EDIT,
  INSERT
}

class CustomerEvent {
  final CustomerEventStatus status;
  final dynamic value;
  final int page;
  final String query;

  const CustomerEvent({this.value, this.status, this.page, this.query});
}

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  CustomerApi localCustomerApi = customerApi;

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
      else if (event.status == CustomerEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
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

  Future<void> _handleFetchAllState(CustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final Customers customers = await localCustomerApi.fetchCustomers(
          query: event.query,
          page: event.page
      );
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
      final Customer customer = await localCustomerApi.fetchCustomer(event.value);
      emit(CustomerLoadedState(customer: customer));
    } catch(e) {
      emit(CustomerErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(CustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      final bool result = await localCustomerApi.deleteCustomer(event.value);
      emit(CustomerDeletedState(result: result));
    } catch(e) {
      emit(CustomerErrorState(message: e.toString()));
    }
  }
}
