import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/mobile/api/mobile_api.dart';
import 'package:my24app/mobile/blocs/assignedorder_states.dart';
import 'package:my24app/mobile/models/models.dart';

enum AssignedOrderEventStatus {
  DO_ASYNC,
  FETCH_ALL
}

class AssignedOrderEvent {
  final dynamic status;
  final dynamic value;

  const AssignedOrderEvent({this.status, this.value});
}

class AssignedOrderBloc extends Bloc<AssignedOrderEvent, AssignedOrderState> {
  MobileApi localMobileApi = mobileApi;
  AssignedOrderBloc(AssignedOrderState initialState) : super(initialState);

  @override
  Stream<AssignedOrderState> mapEventToState(event) async* {
    if (event.status == AssignedOrderEventStatus.DO_ASYNC) {
      yield AssignedOrderLoadingState();
    }

    if (event.status == AssignedOrderEventStatus.FETCH_ALL) {
      try {
        final AssignedOrders assignedOrders = await localMobileApi.fetchAssignedOrders();
        yield AssignedOrdersLoadedState(assignedOrders: assignedOrders);
      } catch (e) {
        yield AssignedOrderErrorState(message: e.toString());
      }
    }

  }
}
