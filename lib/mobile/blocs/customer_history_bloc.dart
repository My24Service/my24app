import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/api/order_api.dart';
import 'package:my24app/mobile/blocs/customer_history_states.dart';
import 'package:my24app/order/models/models.dart';

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
  CustomerHistoryBloc(CustomerHistoryState initialState) : super(initialState);

  @override
  Stream<CustomerHistoryState> mapEventToState(event) async* {
    if (event.status == CustomerHistoryEventStatus.DO_ASYNC) {
      yield CustomerHistoryLoadingState();
    }
    if (event.status == CustomerHistoryEventStatus.FETCH_ALL) {
      try {
        final CustomerHistory customerHistory = await localOrderApi.fetchCustomerHistory(event.value);
        yield CustomerHistoryLoadedState(customerHistory: customerHistory);
      } catch(e) {
        yield CustomerHistoryErrorState(message: e.toString());
      }
    }

  }
}
