import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/mobile/api/mobile_api.dart';
import 'package:my24app/mobile/blocs/activity_states.dart';
import 'package:my24app/mobile/models/models.dart';

enum ActivityEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  DELETE,
  INSERTED
}

class ActivityEvent {
  final dynamic status;
  final AssignedOrderActivity activity;
  final dynamic value;

  const ActivityEvent({this.status, this.activity, this.value});
}

class ActivityBloc extends Bloc<ActivityEvent, AssignedOrderActivityState> {
  MobileApi localMobileApi = mobileApi;
  ActivityBloc(AssignedOrderActivityState initialState) : super(initialState);

  @override
  Stream<AssignedOrderActivityState> mapEventToState(event) async* {
    if (event.status == ActivityEventStatus.DO_ASYNC) {
      yield ActivityLoadingState();
    }
    if (event.status == ActivityEventStatus.FETCH_ALL) {
      try {
        final AssignedOrderActivities activities = await localMobileApi.fetchAssignedOrderActivities(event.value);
        yield ActivitiesLoadedState(activities: activities);
      } catch(e) {
        yield ActivityErrorState(message: e.toString());
      }
    }

    if (event.status == ActivityEventStatus.INSERTED) {
      try {
        yield ActivityInsertedState();
      } catch(e) {
        yield ActivityErrorState(message: e.toString());
      }
    }

    if (event.status == ActivityEventStatus.DELETE) {
      try {
        final bool result = await localMobileApi.deleteAssignedOrderActivity(event.value);
        yield ActivityDeletedState(result: result);
      } catch(e) {
        yield ActivityErrorState(message: e.toString());
      }
    }
  }
}
