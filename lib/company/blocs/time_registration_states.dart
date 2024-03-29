import 'package:equatable/equatable.dart';

import 'package:my24app/company/models/time_registration/models.dart';

abstract class TimeRegistrationState extends Equatable {}

class TimeRegistrationInitialState extends TimeRegistrationState {
  @override
  List<Object> get props => [];
}

class TimeRegistrationLoadingState extends TimeRegistrationState {
  @override
  List<Object> get props => [];
}

class TimeRegistrationErrorState extends TimeRegistrationState {
  final String? message;

  TimeRegistrationErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class TimeRegistrationLoadedState extends TimeRegistrationState {
  final TimeRegistration? timeRegistrationData;
  final DateTime? startDate;
  final String? mode;
  final int? userId;

  TimeRegistrationLoadedState({
    this.timeRegistrationData,
    this.startDate,
    this.mode,
    this.userId
  });

  @override
  List<Object?> get props => [timeRegistrationData, startDate, mode, userId];
}

class TimeRegistrationModeSwitchState extends TimeRegistrationState {
  final TimeRegistration? timeRegistrationData;
  final DateTime? startDate;
  final String? mode;
  final int? userId;

  TimeRegistrationModeSwitchState({
    this.timeRegistrationData,
    this.startDate,
    this.mode,
    this.userId
  });

  @override
  List<Object?> get props => [timeRegistrationData, startDate, mode, userId];
}
