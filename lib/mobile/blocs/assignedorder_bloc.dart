import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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

    if (event.status == AssignedOrderEventStatus.FETCH_DETAIL) {
      try {
        final AssignedOrder assignedOrder = await localMobileApi.fetchAssignedOrder(event.value);
        yield AssignedOrderLoadedState(assignedOrder: assignedOrder);
      } catch (e) {
        yield AssignedOrderErrorState(message: e.toString());
      }
    }

    if (event.status == AssignedOrderEventStatus.REPORT_STARTCODE) {
      try {
        final bool result = await localMobileApi.reportStartCode(event.code, event.value);
        yield AssignedOrderReportStartCodeState(result: result);
      } catch (e) {
        yield AssignedOrderErrorState(message: e.toString());
      }
    }

    if (event.status == AssignedOrderEventStatus.REPORT_ENDCODE) {
      try {
        final bool result = await localMobileApi.reportEndCode(event.code, event.value);
        yield AssignedOrderReportEndCodeState(result: result);
      } catch (e) {
        yield AssignedOrderErrorState(message: e.toString());
      }
    }

    if (event.status == AssignedOrderEventStatus.REPORT_AFTER_ENDCODE) {
      try {
        final bool result = await localMobileApi.reportAfterEndCode(
            event.code,
            event.value,
            event.extraData,
        );
        yield AssignedOrderReportAfterEndCodeState(code: event.code, result: result);
      } catch (e) {
        yield AssignedOrderErrorState(message: e.toString());
      }
    }

    if (event.status == AssignedOrderEventStatus.REPORT_EXTRAWORK) {
      try {
        final dynamic result = await localMobileApi.createExtraOrder(event.value);
        yield AssignedOrderReportExtraOrderState(result: result);
      } catch (e) {
        yield AssignedOrderErrorState(message: e.toString());
      }
    }

    if (event.status == AssignedOrderEventStatus.REPORT_NOWORKORDER) {
      try {
        final dynamic result = await localMobileApi.reportNoWorkorderFinished(event.value);
        yield AssignedOrderReportNoWorkorderFinishedState(result: result);
      } catch (e) {
        yield AssignedOrderErrorState(message: e.toString());
      }
    }

  }

}
