import 'package:equatable/equatable.dart';

import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/order/models/order/models.dart';

abstract class AssignedOrderState extends Equatable {}

class AssignedOrderInitialState extends AssignedOrderState {
  @override
  List<Object> get props => [];
}

class AssignedOrderLoadingState extends AssignedOrderState {
  @override
  List<Object> get props => [];
}

class AssignedOrderErrorState extends AssignedOrderState {
  final String message;

  AssignedOrderErrorState({this.message});

  @override
  List<Object> get props => [message];
}

// load states
class AssignedOrderLoadedState extends AssignedOrderState {
  final AssignedOrder assignedOrder;

  AssignedOrderLoadedState({this.assignedOrder});

  @override
  List<Object> get props => [assignedOrder];
}

class AssignedOrdersLoadedState extends AssignedOrderState {
  final AssignedOrders assignedOrders;
  final String query;
  final int page;

  AssignedOrdersLoadedState({this.assignedOrders, this.query, this.page});

  @override
  List<Object> get props => [assignedOrders, query, page];
}

// report states
class AssignedOrderReportStartCodeState extends AssignedOrderState {
  final bool result;
  final int pk;

  AssignedOrderReportStartCodeState({
    this.result,
    this.pk
  });

  @override
  List<Object> get props => [result, pk];
}

class AssignedOrderReportEndCodeState extends AssignedOrderState {
  final bool result;
  final int pk;

  AssignedOrderReportEndCodeState({
    this.result,
    this.pk
  });

  @override
  List<Object> get props => [result, pk];
}

class AssignedOrderReportAfterEndCodeState extends AssignedOrderState {
  final bool result;
  final AfterEndCode code;
  final String extraData;
  final int pk;

  AssignedOrderReportAfterEndCodeState({
    this.result,
    this.code,
    this.extraData,
    this.pk
  });

  @override
  List<Object> get props => [result, code, extraData, pk];
}

class AssignedOrderReportExtraOrderState extends AssignedOrderState {
  final dynamic result;
  final int pk;

  AssignedOrderReportExtraOrderState({
    this.result,
    this.pk
  });

  @override
  List<Object> get props => [result, pk];
}

class AssignedOrderReportNoWorkorderFinishedState extends AssignedOrderState {
  final bool result;
  final int pk;

  AssignedOrderReportNoWorkorderFinishedState({
    this.result,
    this.pk
  });

  @override
  List<Object> get props => [result, pk];
}
