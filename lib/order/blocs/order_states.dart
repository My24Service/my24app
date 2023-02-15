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
  final int page;

  OrdersLoadedState({this.orders, this.query, this.page});

  @override
  List<Object> get props => [orders, query, page];
}

class OrdersUnacceptedLoadedState extends OrderState {
  final Orders orders;
  final String query;
  final int page;

  OrdersUnacceptedLoadedState({this.orders, this.query, this.page});

  @override
  List<Object> get props => [orders, query, page];
}

class OrdersUnassignedLoadedState extends OrderState {
  final Orders orders;
  final String query;
  final int page;

  OrdersUnassignedLoadedState({this.orders, this.query, this.page});

  @override
  List<Object> get props => [orders, query, page];
}

class OrdersPastLoadedState extends OrderState {
  final Orders orders;
  final String query;
  final int page;

  OrdersPastLoadedState({this.orders, this.query, this.page});

  @override
  List<Object> get props => [orders, query, page];
}

class OrdersSalesLoadedState extends OrderState {
  final Orders orders;
  final String query;
  final int page;

  OrdersSalesLoadedState({this.orders, this.query, this.page});

  @override
  List<Object> get props => [orders, query, page];
}

class OrderDeletedState extends OrderState {
  final bool result;

  OrderDeletedState({this.result});

  @override
  List<Object> get props => [result];
}

class OrderEditedState extends OrderState {
  final Order order;

  OrderEditedState({this.order});

  @override
  List<Object> get props => [order];
}
