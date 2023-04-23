import 'package:equatable/equatable.dart';

import 'package:my24app/company/models/leave_type/form_data.dart';
import 'package:my24app/company/models/leave_type/models.dart';

abstract class LeaveTypeState extends Equatable {}

class LeaveTypeInitialState extends LeaveTypeState {
  @override
  List<Object> get props => [];
}

class LeaveTypeLoadingState extends LeaveTypeState {
  @override
  List<Object> get props => [];
}

class LeaveTypeSearchState extends LeaveTypeState {
  @override
  List<Object> get props => [];
}

class LeaveTypeErrorState extends LeaveTypeState {
  final String message;

  LeaveTypeErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class LeaveTypeInsertedState extends LeaveTypeState {
  final LeaveType leaveType;

  LeaveTypeInsertedState({this.leaveType});

  @override
  List<Object> get props => [leaveType];
}


class LeaveTypeUpdatedState extends LeaveTypeState {
  final LeaveType leaveType;

  LeaveTypeUpdatedState({this.leaveType});

  @override
  List<Object> get props => [leaveType];
}

class LeaveTypesLoadedState extends LeaveTypeState {
  final LeaveTypes leaveTypes;
  final int page;
  final String query;

  LeaveTypesLoadedState({
    this.leaveTypes,
    this.page,
    this.query
  });

  @override
  List<Object> get props => [leaveTypes, page, query];
}

class LeaveTypeLoadedState extends LeaveTypeState {
  final LeaveTypeFormData formData;

  LeaveTypeLoadedState({this.formData});

  @override
  List<Object> get props => [formData];
}

class LeaveTypeNewState extends LeaveTypeState {
  final LeaveTypeFormData formData;

  LeaveTypeNewState({this.formData});

  @override
  List<Object> get props => [formData];
}

class LeaveTypeDeletedState extends LeaveTypeState {
  final bool result;

  LeaveTypeDeletedState({this.result});

  @override
  List<Object> get props => [result];
}
