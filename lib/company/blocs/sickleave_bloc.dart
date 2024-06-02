import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/company/models/sickleave/api.dart';
import 'package:my24app/company/blocs/sickleave_states.dart';
import 'package:my24app/company/models/sickleave/models.dart';
import 'package:my24app/company/models/sickleave/form_data.dart';
import '../models/leave_type/api.dart';

enum UserSickLeaveEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_UNCONFIRMED,
  FETCH_DETAIL,
  DO_SEARCH,
  NEW,
  DELETE,
  UPDATE,
  INSERT,
  UPDATE_FORM_DATA,
  CONFIRM,
}

class UserSickLeaveEvent {
  final UserSickLeaveEventStatus? status;
  final int? pk;
  final UserSickLeave? userSickLeave;
  final UserSickLeaveFormData? formData;
  final int? page;
  final String? query;
  final bool? isPlanning;
  final bool? isFetchingTotals;

  const UserSickLeaveEvent({
    this.status,
    this.pk,
    this.userSickLeave,
    this.formData,
    this.page,
    this.query,
    this.isPlanning,
    this.isFetchingTotals
  });
}

class UserSickLeaveBloc extends Bloc<UserSickLeaveEvent, UserSickLeaveState> {
  UserSickLeaveApi api = UserSickLeaveApi();
  UserSickLeavePlanningApi planningApi = UserSickLeavePlanningApi();
  LeaveTypeApi leaveTypeApi = LeaveTypeApi();

  UserSickLeaveBloc() : super(UserSickLeaveInitialState()) {
    on<UserSickLeaveEvent>((event, emit) async {
      if (event.status == UserSickLeaveEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == UserSickLeaveEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == UserSickLeaveEventStatus.FETCH_UNCONFIRMED) {
        await _handleFetchUnconfirmed(event, emit);
      }
      else if (event.status == UserSickLeaveEventStatus.FETCH_DETAIL) {
        await _handleFetchState(event, emit);
      }
      else if (event.status == UserSickLeaveEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == UserSickLeaveEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == UserSickLeaveEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == UserSickLeaveEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == UserSickLeaveEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == UserSickLeaveEventStatus.NEW) {
        await _handleNewFormDataState(event, emit);
      }
      else if (event.status == UserSickLeaveEventStatus.CONFIRM) {
        await _handleConfirmState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleUpdateFormDataState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) {
    emit(UserSickLeaveLoadedState(
        formData: event.formData,
        isFetchingTotals: false
    ));
  }

  void _handleDoSearchState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) {
    emit(UserSickLeaveSearchState());
  }

  Future<void> _handleNewFormDataState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    UserSickLeaveFormData formData = UserSickLeaveFormData.createEmpty();

    emit(UserSickLeaveNewState(
        formData: formData,
        isFetchingTotals: false
    ));
  }

  void _handleDoAsyncState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) {
    emit(UserSickLeaveLoadingState());
  }

  Future<void> _handleFetchAllState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      Map<String, dynamic> filters = {
        'q': event.query,
        'page': event.page
      };

      final UserSickLeavePaginated userSickLeavePaginated = event.isPlanning! ? await planningApi.list(filters: filters) : await api.list(filters: filters);
      emit(UserSickLeavePaginatedLoadedState(
          userSickLeavePaginated: userSickLeavePaginated
      ));
    } catch(e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnconfirmed(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final UserSickLeavePaginated userSickLeavePaginated = await planningApi.fetchUnconfirmed(
          page: event.page,
          query: event.query
      );
      emit(UserSickLeaveUnacceptedPaginatedLoadedState(
          userSickLeavePaginated: userSickLeavePaginated,
          query: event.query, page: event.page));
    } catch (e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final UserSickLeave userSickLeave = event.isPlanning! ? await planningApi.detail(event.pk!) : await api.detail(event.pk!);
      emit(UserSickLeaveLoadedState(
          formData: UserSickLeaveFormData.createFromModel(userSickLeave),
          isFetchingTotals: false
      ));
    } catch(e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final UserSickLeave userSickLeave = event.isPlanning! ? await planningApi.insert(event.userSickLeave!) : await api.insert(event.userSickLeave!);
      emit(UserSickLeaveInsertedState(userSickLeave: userSickLeave));
    } catch(e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final UserSickLeave userSickLeave = event.isPlanning! ?
        await planningApi.update(event.pk!, event.userSickLeave!) :
        await api.update(event.pk!, event.userSickLeave!);
      emit(UserSickLeaveUpdatedState(userSickLeave: userSickLeave));
    } catch(e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final bool result = event.isPlanning! ? await planningApi.delete(event.pk!) : await api.delete(event.pk!);
      emit(UserSickLeaveDeletedState(result: result));
    } catch(e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }

  Future<void> _handleConfirmState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final bool result = await planningApi.setConfirmed(event.pk!);
      emit(UserSickLeaveAcceptedState(result: result));
    } catch (e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }
}
