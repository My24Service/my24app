import 'package:equatable/equatable.dart';

import 'package:my24app/order/models/models.dart';

abstract class OrderState extends Equatable {}

class OrderInitialState extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderLoadingState extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderErrorState extends OrderState {
  final String message;

  OrderErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class OrderLoadedState extends OrderState {
  final Order order;

  OrderLoadedState({this.order});

  @override
  List<Object> get props => [order];
}

class OrdersLoadedState extends OrderState {
  final Orders orders;

  OrdersLoadedState({this.orders});

  @override
  List<Object> get props => [orders];
}

class OrdersProcessingLoadedState extends OrderState {
  final Orders orders;

  OrdersProcessingLoadedState({this.orders});

  @override
  List<Object> get props => [orders];
}

class OrderDeletedState extends OrderState {
  final bool result;

  OrderDeletedState({this.result});

  @override
  List<Object> get props => [result];
}

class OrderEditState extends OrderState {
  final Order order;

  OrderEditState({this.order});

  @override
  List<Object> get props => [order];
}

class OrderInsertedState extends OrderState {
  final Order order;

  OrderInsertedState({this.order});

  @override
  List<Object> get props => [order];
}

class OrderAcceptedState extends OrderState {
  final bool result;

  OrderAcceptedState({this.result});

  @override
  List<Object> get props => [result];
}
