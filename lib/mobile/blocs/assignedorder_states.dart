import 'package:equatable/equatable.dart';

import 'package:my24app/mobile/models/models.dart';

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

  AssignedOrdersLoadedState({this.assignedOrders});

  @override
  List<Object> get props => [assignedOrders];
}

// report states
class AssignedOrderReportStartCodeState extends AssignedOrderState {
  final bool result;

  AssignedOrderReportStartCodeState({this.result});

  @override
  List<Object> get props => [result];
}

class AssignedOrderReportEndCodeState extends AssignedOrderState {
  final bool result;

  AssignedOrderReportEndCodeState({this.result});

  @override
  List<Object> get props => [result];
}

class AssignedOrderReportExtraOrderState extends AssignedOrderState {
  final dynamic result;

  AssignedOrderReportExtraOrderState({this.result});

  @override
  List<Object> get props => [result];
}

class AssignedOrderReportNoWorkorderFinishedState extends AssignedOrderState {
  final bool result;

  AssignedOrderReportNoWorkorderFinishedState({this.result});

  @override
  List<Object> get props => [result];
}

