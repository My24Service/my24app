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
