import 'package:equatable/equatable.dart';

import 'package:my24app/customer/models/models.dart';

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
  final Customer customer;

  CustomerLoadedState({this.customer});

  @override
  List<Object> get props => [customer];
}

class CustomersLoadedState extends CustomerState {
  final Customers customers;
  final String query;

  CustomersLoadedState({this.customers, this.query});

  @override
  List<Object> get props => [customers];
}

class CustomerErrorState extends CustomerState {
  final String message;

  CustomerErrorState({this.message});

  @override
  List<Object> get props => [message];
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
