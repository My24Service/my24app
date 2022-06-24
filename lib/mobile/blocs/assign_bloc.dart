import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/mobile/api/mobile_api.dart';
import 'package:my24app/mobile/blocs/assign_states.dart';
import 'package:my24app/order/api/order_api.dart';
import 'package:my24app/order/models/models.dart';

enum AssignEventStatus {
  DO_ASYNC,
  FETCH_ORDER,
  ASSIGN,
  ASSIGN_ME
}

class AssignEvent {
  final List<int> engineerPks;
  final String orderId;
  final int orderPk;
  final dynamic status;

  const AssignEvent({this.engineerPks, this.orderId, this.status, this.orderPk});
}

class AssignBloc extends Bloc<AssignEvent, AssignState> {
  MobileApi localMobileApi = mobileApi;
  OrderApi localOrderApi = orderApi;

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
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(AssignEvent event, Emitter<AssignState> emit) {
    emit(AssignLoadingState());
  }

  Future<void> _handleFetchOrderState(AssignEvent event, Emitter<AssignState> emit) async {
    try {
      final Order order = await localOrderApi.fetchOrder(event.orderPk);
      emit(OrderLoadedState(order: order));
    } catch (e) {
      emit(AssignErrorState(message: e.toString()));
    }
  }

  Future<void> _handleAssignState(AssignEvent event, Emitter<AssignState> emit) async {
    try {
      final bool result = await localMobileApi.doAssign(event.engineerPks, event.orderId);
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
