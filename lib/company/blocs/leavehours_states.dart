import 'package:equatable/equatable.dart';

import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/company/models/leavehours/form_data.dart';

abstract class UserLeaveHoursState extends Equatable {}

class UserLeaveHoursInitialState extends UserLeaveHoursState {
  @override
  List<Object> get props => [];
}

class UserLeaveHoursLoadingState extends UserLeaveHoursState {
  @override
  List<Object> get props => [];
}

class UserLeaveHoursTotalsLoadingState extends UserLeaveHoursState {
  final UserLeaveHoursFormData? formData;
  final bool? isFetchingTotals;


  UserLeaveHoursTotalsLoadingState({this.formData, this.isFetchingTotals});

  @override
  List<Object> get props => [];
}

class UserLeaveHoursSearchState extends UserLeaveHoursState {
  @override
  List<Object> get props => [];
}

class UserLeaveHoursErrorState extends UserLeaveHoursState {
  final String? message;

  UserLeaveHoursErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class UserLeaveHoursInsertedState extends UserLeaveHoursState {
  final UserLeaveHours? leaveHours;

  UserLeaveHoursInsertedState({this.leaveHours});

  @override
  List<Object?> get props => [leaveHours];
}


class UserLeaveHoursUpdatedState extends UserLeaveHoursState {
  final UserLeaveHours? leaveHours;

  UserLeaveHoursUpdatedState({this.leaveHours});

  @override
  List<Object?> get props => [leaveHours];
}

class UserLeaveHoursPaginatedLoadedState extends UserLeaveHoursState {
  final UserLeaveHoursPaginated? leaveHoursPaginated;
  final int? page;
  final String? query;
  final DateTime? startDate;

  UserLeaveHoursPaginatedLoadedState({
    this.leaveHoursPaginated,
    this.page,
    this.query,
    this.startDate
  });

  @override
  List<Object?> get props => [leaveHoursPaginated, page, query, startDate];
}

class UserLeaveHoursUnacceptedPaginatedLoadedState extends UserLeaveHoursState {
  final UserLeaveHoursPaginated? leaveHoursPaginated;
  final int? page;
  final String? query;
  final DateTime? startDate;

  UserLeaveHoursUnacceptedPaginatedLoadedState({
    this.leaveHoursPaginated,
    this.page,
    this.query,
    this.startDate
  });

  @override
  List<Object?> get props => [leaveHoursPaginated, page, query, startDate];
}

class UserLeaveHoursLoadedState extends UserLeaveHoursState {
  final UserLeaveHoursFormData? formData;
  final bool? isFetchingTotals;

  UserLeaveHoursLoadedState({this.formData, this.isFetchingTotals});

  @override
  List<Object?> get props => [formData, isFetchingTotals];
}

class TotalsLoadedState extends UserLeaveHoursState {
  final UserLeaveHoursFormData? formData;
  final LeaveHoursData? totals;

  TotalsLoadedState({this.formData, this.totals});

  @override
  List<Object?> get props => [formData, totals];
}

class UserLeaveHoursNewState extends UserLeaveHoursState {
  final UserLeaveHoursFormData? formData;
  final bool? isFetchingTotals;

  UserLeaveHoursNewState({this.formData, this.isFetchingTotals});

  @override
  List<Object?> get props => [formData];
}

class UserLeaveHoursDeletedState extends UserLeaveHoursState {
  final bool? result;

  UserLeaveHoursDeletedState({this.result});

  @override
  List<Object?> get props => [result];
}

class UserLeaveHoursAcceptedState extends UserLeaveHoursState {
  final bool? result;

  UserLeaveHoursAcceptedState({this.result});

  @override
  List<Object?> get props => [result];
}

class UserLeaveHoursRejectedState extends UserLeaveHoursState {
  final bool? result;

  UserLeaveHoursRejectedState({this.result});

  @override
  List<Object?> get props => [result];
}
