import 'package:equatable/equatable.dart';
import 'package:my24app/order/models/models.dart';

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
  final CustomerHistory customerHistory;

  CustomerHistoryLoadedState({this.customerHistory});

  @override
  List<Object> get props => [customerHistory];
}
