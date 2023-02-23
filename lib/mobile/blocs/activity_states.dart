import 'package:equatable/equatable.dart';

import 'package:my24app/mobile/models/activity/form_data.dart';
import 'package:my24app/mobile/models/activity/models.dart';

abstract class AssignedOrderActivityState extends Equatable {}

class ActivityInitialState extends AssignedOrderActivityState {
  @override
  List<Object> get props => [];
}

class ActivityLoadingState extends AssignedOrderActivityState {
  @override
  List<Object> get props => [];
}

class ActivityErrorState extends AssignedOrderActivityState {
  final String message;

  ActivityErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class ActivityInsertedState extends AssignedOrderActivityState {
  final AssignedOrderActivity activity;

  ActivityInsertedState({this.activity});

  @override
  List<Object> get props => [activity];
}


class ActivityUpdatedState extends AssignedOrderActivityState {
  final AssignedOrderActivity activity;

  ActivityUpdatedState({this.activity});

  @override
  List<Object> get props => [activity];
}

class ActivitiesLoadedState extends AssignedOrderActivityState {
  final AssignedOrderActivities activities;
  final int page;

  ActivitiesLoadedState({this.activities, this.page});

  @override
  List<Object> get props => [activities, page];
}

class ActivityLoadedState extends AssignedOrderActivityState {
  final AssignedOrderActivityFormData activityFormData;

  ActivityLoadedState({this.activityFormData});

  @override
  List<Object> get props => [activityFormData];
}

class ActivityNewState extends AssignedOrderActivityState {
  final AssignedOrderActivityFormData activityFormData;

  ActivityNewState({this.activityFormData});

  @override
  List<Object> get props => [activityFormData];
}

class ActivityDeletedState extends AssignedOrderActivityState {
  final bool result;

  ActivityDeletedState({this.result});

  @override
  List<Object> get props => [result];
}
