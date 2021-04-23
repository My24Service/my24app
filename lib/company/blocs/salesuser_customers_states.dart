import 'package:equatable/equatable.dart';

import 'package:my24app/company/models/models.dart';


abstract class SalesUserCustomerState extends Equatable {}

class SalesUserCustomerInitialState extends SalesUserCustomerState {
  @override
  List<Object> get props => [];
}

class SalesUserCustomerLoadingState extends SalesUserCustomerState {
  @override
  List<Object> get props => [];
}

class SalesUserCustomerErrorState extends SalesUserCustomerState {
  final String message;

  SalesUserCustomerErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class SalesUserCustomersLoadedState extends SalesUserCustomerState {
  final SalesUserCustomers customers;

  SalesUserCustomersLoadedState({this.customers});

  @override
  List<Object> get props => [customers];
}

class SalesUserCustomerDeletedState extends SalesUserCustomerState {
  final bool result;

  SalesUserCustomerDeletedState({this.result});

  @override
  List<Object> get props => [result];
}
