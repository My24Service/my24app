import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/mobile/api/mobile_api.dart';
import 'package:my24app/mobile/blocs/assign_states.dart';
import 'package:my24app/order/api/order_api.dart';
import 'package:my24app/order/models/models.dart';

enum AssignEventStatus {
  DO_ASYNC,
  FETCH_ORDER,
  ASSIGN
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
  AssignBloc(AssignState initialState) : super(initialState);

  @override
  Stream<AssignState> mapEventToState(event) async* {
    if (event.status == AssignEventStatus.DO_ASYNC) {
      yield AssignLoadingState();
    }

    if (event.status == AssignEventStatus.FETCH_ORDER) {
      try {
        final Order order = await localOrderApi.fetchOrder(event.orderPk);
        yield OrderLoadedState(order: order);
      } catch (e) {
        yield AssignErrorState(message: e.toString());
      }
    }

    if (event.status == AssignEventStatus.ASSIGN) {
      try {
        final bool result = await localMobileApi.doAssign(event.engineerPks, event.orderId);
        yield AssignedState(result: result);
      } catch(e) {
        yield AssignErrorState(message: e.toString());
      }
    }

  }
}
