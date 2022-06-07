import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/mobile/api/mobile_api.dart';
import 'package:my24app/mobile/blocs/assignedorder_states.dart';
import 'package:my24app/mobile/models/models.dart';

enum AssignedOrderEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  REPORT_STARTCODE,
  REPORT_ENDCODE,
  REPORT_AFTER_ENDCODE,
  REPORT_EXTRAWORK,
  REPORT_NOWORKORDER,
}

class AssignedOrderEvent {
  final dynamic status;
  final dynamic value;
  final dynamic code;
  final String extraData;

  const AssignedOrderEvent({
    this.status,
    this.value,
    this.code,
    this.extraData
  });
}

class AssignedOrderBloc extends Bloc<AssignedOrderEvent, AssignedOrderState> {
  MobileApi localMobileApi = mobileApi;

  AssignedOrderBloc() : super(AssignedOrderInitialState()) {
    on<AssignedOrderEvent>((event, emit) async {
      if (event.status == AssignedOrderEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == AssignedOrderEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == AssignedOrderEventStatus.FETCH_DETAIL) {
        await _handleFetchDetailState(event, emit);
      }
      else if (event.status == AssignedOrderEventStatus.REPORT_STARTCODE) {
        await _handleReportStartcodeState(event, emit);
      }
      else if (event.status == AssignedOrderEventStatus.REPORT_ENDCODE) {
        await _handleReportEndcodeState(event, emit);
      }
      else if (event.status == AssignedOrderEventStatus.REPORT_AFTER_ENDCODE) {
        await _handleReportAfterEndcodeState(event, emit);
      }
      else if (event.status == AssignedOrderEventStatus.REPORT_EXTRAWORK) {
        await _handleReportExtraWorkState(event, emit);
      }
      else if (event.status == AssignedOrderEventStatus.REPORT_NOWORKORDER) {
      await _handleReportNoWorkorderState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) {
    emit(AssignedOrderLoadingState());
  }

  Future<void> _handleFetchAllState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final AssignedOrders assignedOrders = await localMobileApi
          .fetchAssignedOrders();
      emit(AssignedOrdersLoadedState(assignedOrders: assignedOrders));
    } catch (e) {
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final AssignedOrder assignedOrder = await localMobileApi.fetchAssignedOrder(event.value);
      emit(AssignedOrderLoadedState(assignedOrder: assignedOrder));
    } catch (e) {
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleReportStartcodeState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final bool result = await localMobileApi.reportStartCode(event.code, event.value);
      emit(AssignedOrderReportStartCodeState(result: result));
    } catch (e) {
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleReportEndcodeState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final bool result = await localMobileApi.reportEndCode(event.code, event.value);
      emit(AssignedOrderReportEndCodeState(result: result));
    } catch (e) {
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleReportAfterEndcodeState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final bool result = await localMobileApi.reportAfterEndCode(
        event.code,
        event.value,
        event.extraData,
      );
      emit(AssignedOrderReportAfterEndCodeState(code: event.code, result: result));
    } catch (e) {
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleReportExtraWorkState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final dynamic result = await localMobileApi.createExtraOrder(event.value);
      emit(AssignedOrderReportExtraOrderState(result: result));
    } catch (e) {
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleReportNoWorkorderState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final dynamic result = await localMobileApi.reportNoWorkorderFinished(event.value);
      emit(AssignedOrderReportNoWorkorderFinishedState(result: result));
    } catch (e) {
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }
}
