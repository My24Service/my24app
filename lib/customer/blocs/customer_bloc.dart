import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/customer/api/customer_api.dart';
import 'package:my24app/customer/blocs/customer_states.dart';
import 'package:my24app/customer/models/models.dart';

enum CustomerEventStatus { FETCH_ALL, FETCH_DETAIL, DELETE, EDIT, INSERT }

class CustomerEvent {
  final CustomerEventStatus status;
  final dynamic value;

  const CustomerEvent({this.value, this.status});
}

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  CustomerApi localCustomerApi = customerApi;
  CustomerBloc(CustomerState initialState) : super(initialState);

  @override
  Stream<CustomerState> mapEventToState(event) async* {
    if (event.status == CustomerEventStatus.FETCH_ALL) {
      try {
        final Customers customers = await localCustomerApi.fetchCustomers(query: event.value);
        yield CustomersLoadedState(customers: customers);
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

    if (event.status == CustomerEventStatus.EDIT) {
      try {
        final Customer customer = await localCustomerApi.editCustomer(event.value);
        yield CustomerEditState(customer: customer);
      } catch(e) {
        yield CustomerErrorState(message: e.toString());
      }
    }

    if (event.status == CustomerEventStatus.INSERT) {
      try {
        final Customer customer = await localCustomerApi.insertCustomer(event.value);
        yield CustomerInsertState(customer: customer);
      } catch(e) {
        yield CustomerErrorState(message: e.toString());
      }
    }
  }
}