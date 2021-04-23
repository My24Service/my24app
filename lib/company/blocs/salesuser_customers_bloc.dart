import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/company/api/company_api.dart';
import 'package:my24app/company/blocs/salesuser_customers_states.dart';
import 'package:my24app/company/models/models.dart';

enum SalesUserCustomerEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  DELETE,
}

class SalesUserCustomerEvent {
  final SalesUserCustomerEventStatus status;
  final int orderPk;
  final dynamic value;

  const SalesUserCustomerEvent({this.value, this.orderPk, this.status});
}

class SalesUserCustomerBloc extends Bloc<SalesUserCustomerEvent, SalesUserCustomerState> {
  CompanyApi localCompanyApi = companyApi;
  SalesUserCustomerBloc(SalesUserCustomerState initialState) : super(initialState);

  @override
  Stream<SalesUserCustomerState> mapEventToState(event) async* {
    if (event.status == SalesUserCustomerEventStatus.DO_ASYNC) {
      yield SalesUserCustomerLoadingState();
    }

    if (event.status == SalesUserCustomerEventStatus.FETCH_ALL) {
      try {
        final SalesUserCustomers customers = await localCompanyApi.fetchSalesUserCustomers();
        yield SalesUserCustomersLoadedState(customers: customers);
      } catch(e) {
        yield SalesUserCustomerErrorState(message: e.toString());
      }
    }

    if (event.status == SalesUserCustomerEventStatus.DELETE) {
      try {
        final bool result = await localCompanyApi.deleteSalesUserCustomer(event.value);
        yield SalesUserCustomerDeletedState(result: result);
      } catch(e) {
        yield SalesUserCustomerErrorState(message: e.toString());
      }
    }
  }
}
