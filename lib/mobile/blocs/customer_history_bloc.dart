import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/order/api/order_api.dart';
import 'package:my24app/mobile/blocs/customer_history_states.dart';
import 'package:my24app/order/models/order/models.dart';

enum CustomerHistoryEventStatus {
  DO_ASYNC,
  FETCH_ALL
}

class CustomerHistoryEvent {
  final dynamic status;
  final CustomerHistory customerHistory;
  final dynamic value;

  const CustomerHistoryEvent({this.status, this.customerHistory, this.value});
}

class CustomerHistoryBloc extends Bloc<CustomerHistoryEvent, CustomerHistoryState> {
  OrderApi localOrderApi = orderApi;

  CustomerHistoryBloc() : super(CustomerHistoryInitialState()) {
    on<CustomerHistoryEvent>((event, emit) async {
      if (event.status == CustomerHistoryEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == CustomerHistoryEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(CustomerHistoryEvent event, Emitter<CustomerHistoryState> emit) {
    emit(CustomerHistoryLoadingState());
  }

  Future<void> _handleFetchAllState(CustomerHistoryEvent event, Emitter<CustomerHistoryState> emit) async {
    try {
      final CustomerHistory customerHistory = await localOrderApi.fetchCustomerHistory(event.value);
      emit(CustomerHistoryLoadedState(customerHistory: customerHistory));
    } catch(e) {
      emit(CustomerHistoryErrorState(message: e.toString()));
    }
  }
}
