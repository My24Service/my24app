import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/mobile/blocs/activity_states.dart';
import 'package:my24app/mobile/models/activity/api.dart';
import 'package:my24app/mobile/models/activity/form_data.dart';
import 'package:my24app/mobile/models/activity/models.dart';

enum ActivityEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  NEW,
  DELETE,
  UPDATE,
  INSERT,
  UPDATE_FORM_DATA
}

class ActivityEvent {
  final int pk;
  final int assignedOrderId;
  final dynamic status;
  final AssignedOrderActivity activity;
  final AssignedOrderActivityFormData activityFormData;

  const ActivityEvent({
    this.pk,
    this.assignedOrderId,
    this.status,
    this.activity,
    this.activityFormData,
  });
}

class ActivityBloc extends Bloc<ActivityEvent, AssignedOrderActivityState> {
  ActivityApi api = ActivityApi();

  ActivityBloc() : super(ActivityInitialState()) {
    on<ActivityEvent>((event, emit) async {
      if (event.status == ActivityEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == ActivityEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == ActivityEventStatus.FETCH_DETAIL) {
        await _handleFetchState(event, emit);
      }
      else if (event.status == ActivityEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == ActivityEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == ActivityEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == ActivityEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == ActivityEventStatus.NEW) {
        _handleNewFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleUpdateFormDataState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) {
    emit(ActivityLoadedState(activityFormData: event.activityFormData));
  }

  void _handleNewFormDataState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) {
    emit(ActivityNewState(
        activityFormData: AssignedOrderActivityFormData.createEmpty(event.assignedOrderId)
    ));
  }

  void _handleDoAsyncState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) {
    emit(ActivityLoadingState());
  }

  Future<void> _handleFetchAllState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    try {
      final AssignedOrderActivities activities = await api.list(
          filters: {"assigned_order": event.assignedOrderId});
      emit(ActivitiesLoadedState(activities: activities));
    } catch(e) {
      emit(ActivityErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    try {
      final AssignedOrderActivity activity = await api.detail(event.pk);
      emit(ActivityLoadedState(
          activityFormData: AssignedOrderActivityFormData.createFromModel(activity)
      ));
    } catch(e) {
      emit(ActivityErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    try {
      final AssignedOrderActivity activity = await api.insert(
          event.activity);
      emit(ActivityInsertedState(activity: activity));
    } catch(e) {
      emit(ActivityErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    try {
      final AssignedOrderActivity activity = await api.update(event.pk, event.activity);
      emit(ActivityUpdatedState(activity: activity));
    } catch(e) {
      emit(ActivityErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    try {
      final bool result = await api.delete(event.pk);
      emit(ActivityDeletedState(result: result));
    } catch(e) {
      print(e);
      emit(ActivityErrorState(message: e.toString()));
    }
  }
}
