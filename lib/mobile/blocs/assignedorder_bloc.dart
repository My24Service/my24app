import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:logging/logging.dart';

import 'package:my24app/mobile/blocs/assignedorder_states.dart';
import 'package:my24app/mobile/models/assignedorder/models.dart';
import 'package:my24app/mobile/models/assignedorder/api.dart';

final log = Logger('mobile.blocs.assignedorder_bloc');

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
  final AssignedOrderEventStatus? status;
  final dynamic code;
  final String? extraData;
  final int? page;
  final String? query;
  final int? pk;

  const AssignedOrderEvent({
    this.status,
    this.code,
    this.extraData,
    this.page,
    this.query,
    this.pk
  });
}

class AssignedOrderBloc extends Bloc<AssignedOrderEvent, AssignedOrderState> {
  AssignedOrderApi api = AssignedOrderApi();

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
      final AssignedOrders assignedOrders = await api.fetchAssignedOrders(
          query: event.query,
          page: event.page
      );
      emit(AssignedOrdersLoadedState(
          assignedOrders: assignedOrders,
          query: event.query,
          page: event.page
      ));
    } catch (e, trace) {
      log.severe("exception in all: $e\n$trace");
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final AssignedOrder assignedOrder = await api.fetchAssignedOrder(event.pk!);
      emit(AssignedOrderLoadedState(assignedOrder: assignedOrder));
    } catch (e, trace) {
      log.severe("exception in detail: $e\n$trace");
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleReportStartcodeState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final bool result = await api.reportStartCode(event.code, event.pk!);
      emit(AssignedOrderReportStartCodeState(result: result, pk: event.pk));
    } catch (e, trace) {
      log.severe("exception report startcode: $e\n$trace");
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleReportEndcodeState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final bool result = await api.reportEndCode(event.code, event.pk!);
      emit(AssignedOrderReportEndCodeState(result: result, pk: event.pk));
    } catch (e, trace) {
      log.severe("exception report endcode: $e\n$trace");
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleReportAfterEndcodeState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final bool result = await api.reportAfterEndCode(
        event.code,
        event.pk!,
        event.extraData,
      );
      emit(AssignedOrderReportAfterEndCodeState(code: event.code, result: result, pk: event.pk));
    } catch (e, trace) {
      log.severe("exception report after endcode: $e\n$trace");
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleReportExtraWorkState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final dynamic result = await api.createExtraOrder(event.pk!);
      emit(AssignedOrderReportExtraOrderState(result: result, pk: event.pk));
    } catch (e, trace) {
      log.severe("exception report extra work: $e\n$trace");
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }

  Future<void> _handleReportNoWorkorderState(AssignedOrderEvent event, Emitter<AssignedOrderState> emit) async {
    try {
      final dynamic result = await api.reportNoWorkorderFinished(event.pk!);
      emit(AssignedOrderReportNoWorkorderFinishedState(result: result, pk: event.pk));
    } catch (e, trace) {
      log.severe("exception report no workorder: $e\n$trace");
      emit(AssignedOrderErrorState(message: e.toString()));
    }
  }
}
