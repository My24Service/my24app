import 'package:equatable/equatable.dart';
import 'package:my24app/order/models/order/models.dart';

import '../models/assign/form_data.dart';

abstract class AssignState extends Equatable {}

class AssignInitialState extends AssignState {
  @override
  List<Object> get props => [];
}

class AssignLoadingState extends AssignState {
  @override
  List<Object> get props => [];
}

class AssignErrorState extends AssignState {
  final String message;

  AssignErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class AssignedState extends AssignState {
  final bool result;

  AssignedState({this.result});

  @override
  List<Object> get props => [result];
}

class AssignedMeState extends AssignState {
  final bool result;

  AssignedMeState({this.result});

  @override
  List<Object> get props => [result];
}

class OrderLoadedState extends AssignState {
  final Order order;
  final AssignOrderFormData formData;

  OrderLoadedState({this.order, this.formData});

  @override
  List<Object> get props => [order, formData];
}
