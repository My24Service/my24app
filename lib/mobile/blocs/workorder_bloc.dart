import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

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

  WorkorderBloc() : super(WorkorderDataInitialState()) {
    on<WorkorderEvent>((event, emit) async {
      if (event.status == WorkorderEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      if (event.status == WorkorderEventStatus.FETCH) {
        await _handleFetchState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(WorkorderEvent event, Emitter<WorkorderDataState> emit) {
    emit(WorkorderDataLoadingState());
  }

  Future<void> _handleFetchState(WorkorderEvent event, Emitter<WorkorderDataState> emit) async {
    try {
      final AssignedOrderWorkOrderSign workorderData = await localMobileApi
          .fetchAssignedOrderWorkOrderSign(event.value);
      emit(WorkorderDataLoadedState(workorderData: workorderData));
    } catch (e) {
      emit(WorkorderDataErrorState(message: e.toString()));
    }
  }
}
