import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

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

  ActivityBloc() : super(ActivityInitialState()) {
    on<ActivityEvent>((event, emit) async {
      if (event.status == ActivityEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == ActivityEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == ActivityEventStatus.INSERTED) {
        _handleInsertedState(event, emit);
      }
      else if (event.status == ActivityEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) {
    emit(ActivityLoadingState());
  }

  Future<void> _handleFetchAllState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    try {
      final AssignedOrderActivities activities = await localMobileApi.fetchAssignedOrderActivities(event.value);
      emit(ActivitiesLoadedState(activities: activities));
    } catch(e) {
      emit(ActivityErrorState(message: e.toString()));
    }
  }

  void _handleInsertedState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) {
    try {
      emit(ActivityInsertedState());
    } catch (e) {
      emit(ActivityErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    try {
      final bool result = await localMobileApi.deleteAssignedOrderActivity(event.value);
      emit(ActivityDeletedState(result: result));
    } catch(e) {
      emit(ActivityErrorState(message: e.toString()));
    }
  }
}
