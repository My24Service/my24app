import 'package:equatable/equatable.dart';

import 'package:my24app/company/models/sickleave/models.dart';
import 'package:my24app/company/models/sickleave/form_data.dart';

abstract class UserSickLeaveState extends Equatable {}

class UserSickLeaveInitialState extends UserSickLeaveState {
  @override
  List<Object> get props => [];
}

class UserSickLeaveLoadingState extends UserSickLeaveState {
  @override
  List<Object> get props => [];
}

class UserSickLeaveTotalsLoadingState extends UserSickLeaveState {
  final UserSickLeaveFormData? formData;
  final bool? isFetchingTotals;


  UserSickLeaveTotalsLoadingState({this.formData, this.isFetchingTotals});

  @override
  List<Object> get props => [];
}

class UserSickLeaveSearchState extends UserSickLeaveState {
  @override
  List<Object> get props => [];
}

class UserSickLeaveErrorState extends UserSickLeaveState {
  final String? message;

  UserSickLeaveErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class UserSickLeaveInsertedState extends UserSickLeaveState {
  final UserSickLeave? userSickLeave;

  UserSickLeaveInsertedState({this.userSickLeave});

  @override
  List<Object?> get props => [userSickLeave];
}


class UserSickLeaveUpdatedState extends UserSickLeaveState {
  final UserSickLeave? userSickLeave;

  UserSickLeaveUpdatedState({this.userSickLeave});

  @override
  List<Object?> get props => [userSickLeave];
}

class UserSickLeavePaginatedLoadedState extends UserSickLeaveState {
  final UserSickLeavePaginated? userSickLeavePaginated;
  final int? page;
  final String? query;
  final DateTime? startDate;

  UserSickLeavePaginatedLoadedState({
    this.userSickLeavePaginated,
    this.page,
    this.query,
    this.startDate
  });

  @override
  List<Object?> get props => [userSickLeavePaginated, page, query, startDate];
}

class UserSickLeaveUnacceptedPaginatedLoadedState extends UserSickLeaveState {
  final UserSickLeavePaginated? userSickLeavePaginated;
  final int? page;
  final String? query;
  final DateTime? startDate;

  UserSickLeaveUnacceptedPaginatedLoadedState({
    this.userSickLeavePaginated,
    this.page,
    this.query,
    this.startDate
  });

  @override
  List<Object?> get props => [userSickLeavePaginated, page, query, startDate];
}

class UserSickLeaveLoadedState extends UserSickLeaveState {
  final UserSickLeaveFormData? formData;
  final bool? isFetchingTotals;

  UserSickLeaveLoadedState({this.formData, this.isFetchingTotals});

  @override
  List<Object?> get props => [formData, isFetchingTotals];
}

class UserSickLeaveNewState extends UserSickLeaveState {
  final UserSickLeaveFormData? formData;
  final bool? isFetchingTotals;

  UserSickLeaveNewState({this.formData, this.isFetchingTotals});

  @override
  List<Object?> get props => [formData];
}

class UserSickLeaveDeletedState extends UserSickLeaveState {
  final bool? result;

  UserSickLeaveDeletedState({this.result});

  @override
  List<Object?> get props => [result];
}

class UserSickLeaveAcceptedState extends UserSickLeaveState {
  final bool? result;

  UserSickLeaveAcceptedState({this.result});

  @override
  List<Object?> get props => [result];
}

class UserSickLeaveRejectedState extends UserSickLeaveState {
  final bool? result;

  UserSickLeaveRejectedState({this.result});

  @override
  List<Object?> get props => [result];
}
