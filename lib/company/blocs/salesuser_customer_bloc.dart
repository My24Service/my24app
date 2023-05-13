import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/company/blocs/salesuser_customer_states.dart';
import 'package:my24app/company/models/salesuser_customer/models.dart';
import 'package:my24app/company/models/salesuser_customer/api.dart';
import 'package:my24app/company/models/salesuser_customer/form_data.dart';

enum SalesUserCustomerEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  DO_SEARCH,
  DELETE,
  INSERT,
  UPDATE_FORM_DATA,
}

class SalesUserCustomerEvent {
  final SalesUserCustomerEventStatus status;
  final int pk;
  final SalesUserCustomerFormData formData;
  final int page;
  final String query;
  final SalesUserCustomer salesUserCustomer;
  final SalesUserCustomers salesUserCustomers;

  const SalesUserCustomerEvent({
    this.status,
    this.pk,
    this.formData,
    this.page,
    this.query,
    this.salesUserCustomer,
    this.salesUserCustomers
  });
}

class SalesUserCustomerBloc extends Bloc<SalesUserCustomerEvent, SalesUserCustomerState> {
  SalesUserCustomerApi api = SalesUserCustomerApi();

  SalesUserCustomerBloc() : super(SalesUserCustomerInitialState()) {
    on<SalesUserCustomerEvent>((event, emit) async {
      if (event.status == SalesUserCustomerEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == SalesUserCustomerEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == SalesUserCustomerEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == SalesUserCustomerEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == SalesUserCustomerEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == SalesUserCustomerEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(SalesUserCustomerEvent event, Emitter<SalesUserCustomerState> emit) {
    emit(SalesUserCustomerLoadingState());
  }

  void _handleUpdateFormDataState(SalesUserCustomerEvent event, Emitter<SalesUserCustomerState> emit) {
    emit(SalesUserCustomersLoadedState(
        formData: event.formData,
        salesUserCustomers: event.salesUserCustomers
    ));
  }

  Future<void> _handleFetchAllState(SalesUserCustomerEvent event, Emitter<SalesUserCustomerState> emit) async {
    try {
      final SalesUserCustomers salesUserCustomers = await api.list(
          filters: {
            'q': event.query,
            'page': event.page
          });
      emit(SalesUserCustomersLoadedState(
          salesUserCustomers: salesUserCustomers,
          formData: SalesUserCustomerFormData.createEmpty()
      ));
    } catch(e) {
      emit(SalesUserCustomerErrorState(message: e.toString()));
    }
  }

  void _handleDoSearchState(SalesUserCustomerEvent event, Emitter<SalesUserCustomerState> emit) {
    emit(SalesUserCustomerSearchState());
  }

  Future<void> _handleInsertState(SalesUserCustomerEvent event, Emitter<SalesUserCustomerState> emit) async {
    try {
      final SalesUserCustomer salesUserCustomer = await api.insert(event.salesUserCustomer);
      emit(SalesUserCustomerInsertedState(salesUserCustomer: salesUserCustomer));
    } catch(e) {
      emit(SalesUserCustomerErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(SalesUserCustomerEvent event, Emitter<SalesUserCustomerState> emit) async {
    try {
      final bool result = await api.delete(event.pk);
      emit(SalesUserCustomerDeletedState(result: result));
    } catch(e) {
      emit(SalesUserCustomerErrorState(message: e.toString()));
    }
  }
}
