import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/mobile/api/mobile_api.dart';
import 'package:my24app/mobile/blocs/assign_states.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/models/order/api.dart';
import '../models/assign/form_data.dart';

enum AssignEventStatus {
  DO_ASYNC,
  FETCH_ORDER,
  ASSIGN,
  ASSIGN_ME,
  UPDATE_FORM_DATA
}

class AssignEvent {
  final String? orderId;
  final int? orderPk;
  final Order? order;
  final AssignOrderFormData? formData;
  final dynamic status;

  const AssignEvent({
    this.orderId,
    this.order,
    this.status,
    this.orderPk,
    this.formData
  });
}

class AssignBloc extends Bloc<AssignEvent, AssignState> {
  MobileApi localMobileApi = mobileApi;
  OrderApi localOrderApi = OrderApi();

  AssignBloc() : super(AssignInitialState()) {
    on<AssignEvent>((event, emit) async {
      if (event.status == AssignEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == AssignEventStatus.FETCH_ORDER) {
        await _handleFetchOrderState(event, emit);
      }
      else if (event.status == AssignEventStatus.ASSIGN) {
        await _handleAssignState(event, emit);
      }
      else if (event.status == AssignEventStatus.ASSIGN_ME) {
        await _handleAssignMeState(event, emit);
      }
      else if (event.status == AssignEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(AssignEvent event, Emitter<AssignState> emit) {
    emit(AssignLoadingState());
  }

  void _handleUpdateFormDataState(AssignEvent event, Emitter<AssignState> emit) {
    emit(OrderLoadedState(formData: event.formData, order: event.order));
  }

  Future<void> _handleFetchOrderState(AssignEvent event, Emitter<AssignState> emit) async {
    try {
      final Order order = await localOrderApi.detail(event.orderPk!);
      emit(OrderLoadedState(order: order, formData: AssignOrderFormData()));
    } catch (e) {
      emit(AssignErrorState(message: e.toString()));
    }
  }

  Future<void> _handleAssignState(AssignEvent event, Emitter<AssignState> emit) async {
    try {
      final bool result = await localMobileApi.doAssign(event.formData!.selectedEngineerPks, event.orderId);
      emit(AssignedState(result: result));
    } catch(e) {
      emit(AssignErrorState(message: e.toString()));
    }
  }

  Future<void> _handleAssignMeState(AssignEvent event, Emitter<AssignState> emit) async {
    try {
      final bool result = await localMobileApi.doAssignMe(event.orderId);
      emit(AssignedMeState(result: result));
    } catch(e) {
      emit(AssignErrorState(message: e.toString()));
    }
  }
}
