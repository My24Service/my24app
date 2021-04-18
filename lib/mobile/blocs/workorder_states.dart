import 'package:equatable/equatable.dart';
import 'package:my24app/mobile/models/models.dart';

abstract class WorkorderDataState extends Equatable {}

class WorkorderDataInitialState extends WorkorderDataState {
  @override
  List<Object> get props => [];
}

class WorkorderDataLoadingState extends WorkorderDataState {
  @override
  List<Object> get props => [];
}

class WorkorderDataErrorState extends WorkorderDataState {
  final String message;

  WorkorderDataErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class WorkorderDataLoadedState extends WorkorderDataState {
  final AssignedOrderWorkOrderSign workorderData;

  WorkorderDataLoadedState({this.workorderData});

  @override
  List<Object> get props => [workorderData];
}

class WorkorderDataInsertedState extends WorkorderDataState {
  final AssignedOrderWorkOrder workorder;

  WorkorderDataInsertedState({this.workorder});

  @override
  List<Object> get props => [workorder];
}
