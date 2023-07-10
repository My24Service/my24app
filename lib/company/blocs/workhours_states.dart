import 'package:equatable/equatable.dart';

import 'package:my24app/company/models/workhours/models.dart';
import 'package:my24app/company/models/workhours/form_data.dart';

abstract class UserWorkHoursState extends Equatable {}

class UserWorkHoursInitialState extends UserWorkHoursState {
  @override
  List<Object> get props => [];
}

class UserWorkHoursLoadingState extends UserWorkHoursState {
  @override
  List<Object> get props => [];
}

class UserWorkHoursSearchState extends UserWorkHoursState {
  @override
  List<Object> get props => [];
}

class UserWorkHoursErrorState extends UserWorkHoursState {
  final String? message;

  UserWorkHoursErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class UserWorkHoursInsertedState extends UserWorkHoursState {
  final UserWorkHours? workHours;

  UserWorkHoursInsertedState({this.workHours});

  @override
  List<Object?> get props => [workHours];
}


class UserWorkHoursUpdatedState extends UserWorkHoursState {
  final UserWorkHours? workHours;

  UserWorkHoursUpdatedState({this.workHours});

  @override
  List<Object?> get props => [workHours];
}

class UserWorkHoursPaginatedLoadedState extends UserWorkHoursState {
  final UserWorkHoursPaginated? workHoursPaginated;
  final int? page;
  final String? query;
  final DateTime? startDate;

  UserWorkHoursPaginatedLoadedState({
    this.workHoursPaginated,
    this.page,
    this.query,
    this.startDate
  });

  @override
  List<Object?> get props => [workHoursPaginated, page, query, startDate];
}

class UserWorkHoursLoadedState extends UserWorkHoursState {
  final UserWorkHoursFormData? formData;

  UserWorkHoursLoadedState({this.formData});

  @override
  List<Object?> get props => [formData];
}

class UserWorkHoursNewState extends UserWorkHoursState {
  final UserWorkHoursFormData? formData;

  UserWorkHoursNewState({this.formData});

  @override
  List<Object?> get props => [formData];
}

class UserWorkHoursDeletedState extends UserWorkHoursState {
  final bool? result;

  UserWorkHoursDeletedState({this.result});

  @override
  List<Object?> get props => [result];
}
