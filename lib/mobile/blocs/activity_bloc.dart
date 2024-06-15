import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:logging/logging.dart';

import 'package:my24app/mobile/blocs/activity_states.dart';
import 'package:my24app/mobile/models/activity/api.dart';
import 'package:my24app/mobile/models/activity/form_data.dart';
import 'package:my24app/mobile/models/activity/models.dart';

import '../../common/utils.dart';
import '../../company/models/engineer/api.dart';
import '../../company/models/engineer/models.dart';

final log = Logger('activity.bloc');

enum ActivityEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  DO_SEARCH,
  NEW,
  NEW_EMPTY,
  DELETE,
  UPDATE,
  INSERT,
  UPDATE_FORM_DATA
}

class ActivityEvent {
  final int? pk;
  final int? assignedOrderId;
  final dynamic status;
  final AssignedOrderActivity? activity;
  final AssignedOrderActivityFormData? activityFormData;
  final int? page;
  final String? query;

  const ActivityEvent({
    this.pk,
    this.assignedOrderId,
    this.status,
    this.activity,
    this.activityFormData,
    this.page,
    this.query,
  });
}

class ActivityBloc extends Bloc<ActivityEvent, AssignedOrderActivityState> {
  ActivityApi api = ActivityApi();
  Utils utils = Utils();
  EngineersForSelectApi engineersForSelectApi = EngineersForSelectApi();

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
      else if (event.status == ActivityEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
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
        await _handleNewFormDataState(event, emit);
      }
      else if (event.status == ActivityEventStatus.NEW_EMPTY) {
        await _handleNewEmptyFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleUpdateFormDataState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) {
    emit(ActivityLoadedState(activityFormData: event.activityFormData));
  }

  void _handleDoSearchState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) {
    emit(ActivitySearchState());
  }

  Future<void> _handleNewFormDataState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    final bool canChooseEngineers = await utils.engineerCanSelectUsers();
    EngineersForSelect? engineersForSelect = canChooseEngineers ? await engineersForSelectApi.get() : null;

    // select first user
    AssignedOrderActivityFormData activityFormData = AssignedOrderActivityFormData.createEmpty(event.assignedOrderId);
    // if (canChooseEngineers) {
    //   activityFormData.user = engineersForSelect!.engineers![0].user_id;
    // }

    emit(ActivityNewState(
        fromEmpty: false,
        activityFormData: activityFormData,
        engineersForSelect: engineersForSelect
    ));
  }

  Future<void> _handleNewEmptyFormDataState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    final bool canChooseEngineers = await utils.engineerCanSelectUsers();
    EngineersForSelect? engineersForSelect = canChooseEngineers ? await engineersForSelectApi.get() : null;

    emit(ActivityNewState(
        fromEmpty: true,
        activityFormData: AssignedOrderActivityFormData.createEmpty(event.assignedOrderId),
        engineersForSelect: engineersForSelect
    ));
  }

  void _handleDoAsyncState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) {
    emit(ActivityLoadingState());
  }

  Future<void> _handleFetchAllState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    try {
      final bool canChooseEngineers = await utils.engineerCanSelectUsers();
      final AssignedOrderActivities activities = await api.list(
          filters: {
            "assigned_order": event.assignedOrderId,
            'q': event.query,
            'page': event.page
          });

      emit(ActivitiesLoadedState(
          activities: activities,
          query: event.query,
          page: event.page,
          canChooseEngineers: canChooseEngineers
      ));
    } catch(e) {
      log.severe("error fetching all: $e");
      emit(ActivityErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    final bool canChooseEngineers = await utils.engineerCanSelectUsers();
    EngineersForSelect? engineersForSelect = canChooseEngineers ? await engineersForSelectApi.get() : null;

    try {
      final AssignedOrderActivity activity = await api.detail(event.pk!);
      emit(ActivityLoadedState(
          activityFormData: AssignedOrderActivityFormData.createFromModel(activity),
          engineersForSelect: engineersForSelect
      ));
    } catch(e) {
      log.severe("error fetch: $e");
      emit(ActivityErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    try {
      final AssignedOrderActivity activity = await api.insert(
          event.activity!);
      emit(ActivityInsertedState(activity: activity));
    } catch(e) {
      log.severe("error insert: $e");
      emit(ActivityErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    try {
      final AssignedOrderActivity activity = await api.update(event.pk!, event.activity!);
      emit(ActivityUpdatedState(activity: activity));
    } catch(e) {
      log.severe("error edit: $e");
      emit(ActivityErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(ActivityEvent event, Emitter<AssignedOrderActivityState> emit) async {
    try {
      final bool result = await api.delete(event.pk!);
      emit(ActivityDeletedState(result: result));
    } catch(e) {
      log.severe("error delete: $e");
      emit(ActivityErrorState(message: e.toString()));
    }
  }
}
