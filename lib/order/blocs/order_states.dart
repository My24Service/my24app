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

class OrderSearchState extends OrderState {
  @override
  List<Object> get props => [];
}

class OrderRefreshState extends OrderState {
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
  final String query;

  OrdersLoadedState({this.orders, this.query});

  @override
  List<Object> get props => [orders, query];
}

class OrdersUnacceptedLoadedState extends OrderState {
  final Orders orders;
  final String query;

  OrdersUnacceptedLoadedState({this.orders, this.query});

  @override
  List<Object> get props => [orders, query];
}

class OrdersUnassignedLoadedState extends OrderState {
  final Orders orders;
  final String query;

  OrdersUnassignedLoadedState({this.orders, this.query});

  @override
  List<Object> get props => [orders, query];
}

class OrdersPastLoadedState extends OrderState {
  final Orders orders;
  final String query;

  OrdersPastLoadedState({this.orders, this.query});

  @override
  List<Object> get props => [orders, query];
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
