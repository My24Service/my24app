import 'package:equatable/equatable.dart';

import 'package:my24app/customer/models/models.dart';

import '../../order/models/order/models.dart';
import '../models/form_data.dart';

abstract class CustomerState extends Equatable {}

class CustomerInitialState extends CustomerState {
  @override
  List<Object> get props => [];
}

class CustomerLoadingState extends CustomerState {
  @override
  List<Object> get props => [];
}

class CustomerSearchState extends CustomerState {
  @override
  List<Object> get props => [];
}

class CustomerRefreshState extends CustomerState {
  @override
  List<Object> get props => [];
}

class CustomerLoadedState extends CustomerState {
  final CustomerFormData formData;

  CustomerLoadedState({this.formData});

  @override
  List<Object> get props => [formData];
}

class CustomerLoadedViewState extends CustomerState {
  final Customer customer;
  final CustomerHistoryOrders customerHistoryOrders;
  final int page;
  final String query;

  CustomerLoadedViewState({
    this.customer,
    this.customerHistoryOrders,
    this.page,
    this.query,
  });

  @override
  List<Object> get props => [customer, customerHistoryOrders, page, query];
}

class CustomersLoadedState extends CustomerState {
  final Customers customers;
  final int page;
  final String query;

  CustomersLoadedState({
    this.customers,
    this.page,
    this.query,
  });

  @override
  List<Object> get props => [customers, page, query];
}

class CustomerErrorState extends CustomerState {
  final String message;

  CustomerErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class CustomerNewState extends CustomerState {
  final CustomerFormData formData;

  CustomerNewState({this.formData});

  @override
  List<Object> get props => [formData];
}

class CustomerInsertedState extends CustomerState {
  final Customer customer;

  CustomerInsertedState({this.customer});

  @override
  List<Object> get props => [customer];
}


class CustomerUpdatedState extends CustomerState {
  final Customer customer;

  CustomerUpdatedState({this.customer});

  @override
  List<Object> get props => [customer];
}

class CustomerDeletedState extends CustomerState {
  final bool result;

  CustomerDeletedState({this.result});

  @override
  List<Object> get props => [result];
}

class CustomerEditState extends CustomerState {
  final Customer customer;

  CustomerEditState({this.customer});

  @override
  List<Object> get props => [customer];
}

class CustomerInsertState extends CustomerState {
  final Customer customer;

  CustomerInsertState({this.customer});

  @override
  List<Object> get props => [customer];
}
