import 'package:equatable/equatable.dart';

import 'package:my24app/company/models/models.dart';

abstract class UserWorkHoursState extends Equatable {}

class UserWorkHoursInitialState extends UserWorkHoursState {
  @override
  List<Object> get props => [];
}

class UserWorkHoursNewState extends UserWorkHoursState {
  @override
  List<Object> get props => [];
}

class UserWorkHoursLoadingState extends UserWorkHoursState {
  @override
  List<Object> get props => [];
}

class UserWorkHoursErrorState extends UserWorkHoursState {
  final String message;

  UserWorkHoursErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class UserWorkHoursLoadedState extends UserWorkHoursState {
  final UserWorkHoursPaginated results;
  final DateTime startDate;

  UserWorkHoursLoadedState({this.results, this.startDate});

  @override
  List<Object> get props => [results, startDate];
}

class UserWorkHoursInsertedState extends UserWorkHoursState {
  final UserWorkHours hours;

  UserWorkHoursInsertedState({this.hours});

  @override
  List<Object> get props => [hours];
}

class UserWorkHoursEditedState extends UserWorkHoursState {
  final bool result;

  UserWorkHoursEditedState({this.result});

  @override
  List<Object> get props => [result];
}

class UserWorkHoursDeletedState extends UserWorkHoursState {
  final bool result;

  UserWorkHoursDeletedState({this.result});

  @override
  List<Object> get props => [result];
}

class UserWorkHoursDetailLoadedState extends UserWorkHoursState {
  final UserWorkHours hours;

  UserWorkHoursDetailLoadedState({this.hours});

  @override
  List<Object> get props => [hours];
}
