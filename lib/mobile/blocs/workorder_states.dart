import 'package:equatable/equatable.dart';

import '../models/workorder/form_data.dart';
import '../models/workorder/models.dart';

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

class WorkorderDataNewState extends WorkorderDataState {
  final AssignedOrderWorkOrderFormData formData;

  WorkorderDataNewState({this.formData});

  @override
  List<Object> get props => [formData];
}

class WorkorderDataLoadedState extends WorkorderDataState {
  final AssignedOrderWorkOrderFormData formData;

  WorkorderDataLoadedState({this.formData});

  @override
  List<Object> get props => [formData];
}

class WorkorderDataInsertedState extends WorkorderDataState {
  final AssignedOrderWorkOrder workOrder;

  WorkorderDataInsertedState({this.workOrder});

  @override
  List<Object> get props => [workOrder];
}
