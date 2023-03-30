import 'package:equatable/equatable.dart';
import 'package:my24app/order/models/order/models.dart';

abstract class CustomerHistoryState extends Equatable {}

class CustomerHistoryInitialState extends CustomerHistoryState {
  @override
  List<Object> get props => [];
}

class CustomerHistoryLoadingState extends CustomerHistoryState {
  @override
  List<Object> get props => [];
}

class CustomerHistoryErrorState extends CustomerHistoryState {
  final String message;

  CustomerHistoryErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class CustomerHistoryLoadedState extends CustomerHistoryState {
  final CustomerHistoryOrders customerHistoryOrders;
  final String query;
  final int page;

  CustomerHistoryLoadedState({
    this.customerHistoryOrders,
    this.page,
    this.query
  });

  @override
  List<Object> get props => [customerHistoryOrders, page, query];
}
