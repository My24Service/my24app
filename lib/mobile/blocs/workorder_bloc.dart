import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/mobile/api/mobile_api.dart';
import 'package:my24app/mobile/blocs/workorder_states.dart';
import 'package:my24app/mobile/models/models.dart';

enum WorkorderEventStatus {
  DO_ASYNC,
  FETCH,
}

class WorkorderEvent {
  final dynamic status;
  final dynamic value;
  final AssignedOrderWorkOrder workorder;

  const WorkorderEvent({this.status, this.value, this.workorder});
}

class WorkorderBloc extends Bloc<WorkorderEvent, WorkorderDataState> {
  MobileApi localMobileApi = mobileApi;
  WorkorderBloc(WorkorderDataState initialState) : super(initialState);

  @override
  Stream<WorkorderDataState> mapEventToState(event) async* {
    if (event.status == WorkorderEventStatus.DO_ASYNC) {
      yield WorkorderDataLoadingState();
    }

    if (event.status == WorkorderEventStatus.FETCH) {
      try {
        final AssignedOrderWorkOrderSign workorderData = await localMobileApi.fetchAssignedOrderWorkOrderSign(event.value);
        yield WorkorderDataLoadedState(workorderData: workorderData);
      } catch(e) {
        yield WorkorderDataErrorState(message: e.toString());
      }
    }
  }
}
