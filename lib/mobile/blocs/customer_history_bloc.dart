import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/mobile/blocs/customer_history_states.dart';
import 'package:my24app/order/models/order/api.dart';
import 'package:my24app/order/models/order/models.dart';

enum CustomerHistoryEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  DO_SEARCH
}

class CustomerHistoryEvent {
  final dynamic status;
  final CustomerHistoryOrders customerHistoryOrders;
  final int customerPk;
  final int page;
  final String query;

  const CustomerHistoryEvent({
    this.status,
    this.customerHistoryOrders,
    this.customerPk,
    this.page,
    this.query,
  });
}

class CustomerHistoryBloc extends Bloc<CustomerHistoryEvent, CustomerHistoryState> {
  CustomerHistoryOrderApi api = CustomerHistoryOrderApi();

  CustomerHistoryBloc() : super(CustomerHistoryInitialState()) {
    on<CustomerHistoryEvent>((event, emit) async {
      if (event.status == CustomerHistoryEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == CustomerHistoryEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == CustomerHistoryEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(CustomerHistoryEvent event, Emitter<CustomerHistoryState> emit) {
    emit(CustomerHistoryLoadingState());
  }

  void _handleDoSearchState(CustomerHistoryEvent event, Emitter<CustomerHistoryState> emit) {
    emit(CustomerHistorySearchState());
  }

  Future<void> _handleFetchAllState(CustomerHistoryEvent event, Emitter<CustomerHistoryState> emit) async {
    try {
      final CustomerHistoryOrders customerHistoryOrders = await api.list(
          filters: {
            "customer_id": event.customerPk,
            'query': event.query,
            'page': event.page
          });
      emit(CustomerHistoryLoadedState(customerHistoryOrders: customerHistoryOrders));
    } catch(e) {
      emit(CustomerHistoryErrorState(message: e.toString()));
    }
  }
}
