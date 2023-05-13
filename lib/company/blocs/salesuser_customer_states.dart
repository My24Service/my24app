import 'package:equatable/equatable.dart';

import 'package:my24app/company/models/salesuser_customer/models.dart';
import 'package:my24app/company/models/salesuser_customer/form_data.dart';


abstract class SalesUserCustomerState extends Equatable {}

class SalesUserCustomerInitialState extends SalesUserCustomerState {
  @override
  List<Object> get props => [];
}

class SalesUserCustomerLoadingState extends SalesUserCustomerState {
  @override
  List<Object> get props => [];
}

class SalesUserCustomerSearchState extends SalesUserCustomerState {
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
  final SalesUserCustomers salesUserCustomers;
  final SalesUserCustomerFormData formData;
  final int page;
  final String query;

  SalesUserCustomersLoadedState({
    this.salesUserCustomers,
    this.formData,
    this.page,
    this.query
  });

  @override
  List<Object> get props => [salesUserCustomers, formData, page, query];
}

class SalesUserCustomerInsertedState extends SalesUserCustomerState {
  final SalesUserCustomer salesUserCustomer;

  SalesUserCustomerInsertedState({this.salesUserCustomer});

  @override
  List<Object> get props => [salesUserCustomer];
}

class SalesUserCustomerDeletedState extends SalesUserCustomerState {
  final bool result;

  SalesUserCustomerDeletedState({this.result});

  @override
  List<Object> get props => [result];
}
