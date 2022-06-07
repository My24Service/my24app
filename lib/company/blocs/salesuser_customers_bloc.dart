import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

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

  SalesUserCustomerBloc() : super(SalesUserCustomerInitialState()) {
    on<SalesUserCustomerEvent>((event, emit) async {
      if (event.status == SalesUserCustomerEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == SalesUserCustomerEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == SalesUserCustomerEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(SalesUserCustomerEvent event, Emitter<SalesUserCustomerState> emit) {
    emit(SalesUserCustomerLoadingState());
  }

  Future<void> _handleFetchAllState(SalesUserCustomerEvent event, Emitter<SalesUserCustomerState> emit) async {
    try {
      final SalesUserCustomers customers = await localCompanyApi.fetchSalesUserCustomers();
      emit(SalesUserCustomersLoadedState(customers: customers));
    } catch(e) {
      emit(SalesUserCustomerErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(SalesUserCustomerEvent event, Emitter<SalesUserCustomerState> emit) async {
    try {
      final bool result = await localCompanyApi.deleteSalesUserCustomer(event.value);
      emit(SalesUserCustomerDeletedState(result: result));
    } catch(e) {
      emit(SalesUserCustomerErrorState(message: e.toString()));
    }
  }
}
