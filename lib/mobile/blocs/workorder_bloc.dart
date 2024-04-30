import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24_flutter_orders/models/order/api.dart';

import 'package:my24app/mobile/blocs/workorder_states.dart';
import 'package:my24app/mobile/models/workorder/models.dart';
import 'package:my24app/mobile/models/workorder/form_data.dart';
import 'package:my24app/mobile/models/workorder/api.dart';

enum WorkorderEventStatus {
  DO_ASYNC,
  NEW,
  INSERT,
  UPDATE_FORM_DATA,
  CREATE_WORKORDER_PDF
}

class WorkorderEvent {
  final dynamic status;
  final AssignedOrderWorkOrder? workorder;
  final AssignedOrderWorkOrderFormData? formData;
  final int? assignedOrderId;
  final int? orderPk;
  final String? assignedOrderWorkorderId;

  const WorkorderEvent({
    this.status,
    this.workorder,
    this.formData,
    this.assignedOrderId,
    this.orderPk,
    this.assignedOrderWorkorderId
  });
}

class WorkorderBloc extends Bloc<WorkorderEvent, WorkorderDataState> {
  AssignedOrderWorkOrderApi api = AssignedOrderWorkOrderApi();
  OrderApi orderApi = OrderApi();

  WorkorderBloc() : super(WorkorderDataInitialState()) {
    on<WorkorderEvent>((event, emit) async {
      if (event.status == WorkorderEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == WorkorderEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == WorkorderEventStatus.CREATE_WORKORDER_PDF) {
        await _handleCreateWorkorderPdf(event, emit);
      }
      else if (event.status == WorkorderEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == WorkorderEventStatus.NEW) {
        _handleNewFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(WorkorderEvent event, Emitter<WorkorderDataState> emit) {
    emit(WorkorderDataLoadingState());
  }

  Future<void> _handleInsertState(WorkorderEvent event, Emitter<WorkorderDataState> emit) async {
    try {
      final AssignedOrderWorkOrder workOrder = await api.insert(event.workorder!);
      emit(WorkorderDataInsertedState(
          workOrder: workOrder,
          orderPk: event.orderPk
      ));
    } catch(e) {
      emit(WorkorderDataErrorState(message: e.toString()));
    }
  }

  Future<void> _handleCreateWorkorderPdf(WorkorderEvent event, Emitter<WorkorderDataState> emit) async {
    try {
      final bool workorderPdfCreateResult = await orderApi.createWorkorderPdf(
          event.orderPk!, event.assignedOrderId!
      );
      emit(WorkorderPdfCreatedState(result: workorderPdfCreateResult));
    } catch(e) {
      emit(WorkorderDataErrorState(message: e.toString()));
    }
  }

  void _handleUpdateFormDataState(WorkorderEvent event, Emitter<WorkorderDataState> emit) {
    emit(WorkorderDataLoadedState(formData: event.formData));
  }

  void _handleNewFormDataState(WorkorderEvent event, Emitter<WorkorderDataState> emit) {
    emit(WorkorderDataNewState(
        formData: AssignedOrderWorkOrderFormData.createEmpty(event.assignedOrderId)
    ));
  }
}
