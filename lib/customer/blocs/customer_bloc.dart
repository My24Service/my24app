import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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
  CustomerBloc(CustomerState initialState) : super(initialState);

  @override
  Stream<CustomerState> mapEventToState(event) async* {
    if (event.status == CustomerEventStatus.DO_ASYNC) {
      yield CustomerLoadingState();
    }

    if (event.status == CustomerEventStatus.DO_SEARCH) {
      yield CustomerSearchState();
    }

    if (event.status == CustomerEventStatus.DO_REFRESH) {
      yield CustomerRefreshState();
    }

    if (event.status == CustomerEventStatus.FETCH_ALL) {
      try {
        final Customers customers = await localCustomerApi.fetchCustomers(
            query: event.query,
            page: event.page
        );
        yield CustomersLoadedState(
            customers: customers,
            query: event.query
        );
      } catch(e) {
        yield CustomerErrorState(message: e.toString());
      }
    }

    if (event.status == CustomerEventStatus.FETCH_DETAIL) {
      try {
        final Customer customer = await localCustomerApi.fetchCustomer(event.value);
        yield CustomerLoadedState(customer: customer);
      } catch(e) {
        yield CustomerErrorState(message: e.toString());
      }
    }

    if (event.status == CustomerEventStatus.DELETE) {
      try {
        final bool result = await localCustomerApi.deleteCustomer(event.value);
        yield CustomerDeletedState(result: result);
      } catch(e) {
        yield CustomerErrorState(message: e.toString());
      }
    }
  }
}
