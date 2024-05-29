import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/company/models/sickleave/api.dart';
import 'package:my24app/company/blocs/sickleave_states.dart';
import 'package:my24app/company/models/sickleave/models.dart';
import 'package:my24app/company/models/sickleave/form_data.dart';
import '../models/leave_type/api.dart';
import '../models/leave_type/models.dart';

enum UserSickLeaveEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_UNACCEPTED,
  FETCH_DETAIL,
  DO_SEARCH,
  NEW,
  DELETE,
  UPDATE,
  INSERT,
  UPDATE_FORM_DATA,
  DO_GET_TOTALS,
  GET_TOTALS,
  ACCEPT,
  REJECT,
}

class UserSickLeaveEvent {
  final UserSickLeaveEventStatus? status;
  final int? pk;
  final UserSickLeave? leaveHours;
  final UserSickLeaveFormData? formData;
  final int? page;
  final String? query;
  final bool? isPlanning;
  final bool? isFetchingTotals;

  const UserSickLeaveEvent({
    this.status,
    this.pk,
    this.leaveHours,
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
      else if (event.status == UserSickLeaveEventStatus.FETCH_UNACCEPTED) {
        await _handleFetchUnacceptedState(event, emit);
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
      else if (event.status == UserSickLeaveEventStatus.ACCEPT) {
        await _handleAcceptState(event, emit);
      }
      else if (event.status == UserSickLeaveEventStatus.REJECT) {
        await _handleRejectState(event, emit);
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

      final UserSickLeavePaginated leaveHoursPaginated = event.isPlanning! ? await planningApi.list(filters: filters) : await api.list(filters: filters);
      emit(UserSickLeavePaginatedLoadedState(
          leaveHoursPaginated: leaveHoursPaginated
      ));
    } catch(e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnacceptedState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final UserSickLeavePaginated UserSickLeavePaginated = event.isPlanning! ? await planningApi.fetchUnaccepted(
          page: event.page,
          query: event.query
      ) : await api.fetchUnaccepted(
          page: event.page,
          query: event.query
      );
      emit(UserSickLeaveUnacceptedPaginatedLoadedState(
          leaveHoursPaginated: UserSickLeavePaginated,
          query: event.query, page: event.page));
    } catch (e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final UserSickLeave leaveHours = event.isPlanning! ? await planningApi.detail(event.pk!) : await api.detail(event.pk!);
      final LeaveTypes leaveTypes = await leaveTypeApi.fetchLeaveTypesForSelect();
      emit(UserSickLeaveLoadedState(
          formData: UserSickLeaveFormData.createFromModel(leaveTypes, leaveHours),
          isFetchingTotals: false
      ));
    } catch(e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final UserSickLeave leaveHours = event.isPlanning! ? await planningApi.insert(event.leaveHours!) : await api.insert(event.leaveHours!);
      emit(UserSickLeaveInsertedState(leaveHours: leaveHours));
    } catch(e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final UserSickLeave leaveHours = event.isPlanning! ? await planningApi.update(event.pk!, event.leaveHours!) : await api.update(event.pk!, event.leaveHours!);
      emit(UserSickLeaveUpdatedState(leaveHours: leaveHours));
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

  Future<void> _handleAcceptState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final bool result = await planningApi.accept(event.pk!);
      emit(UserSickLeaveAcceptedState(result: result));
    } catch (e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }

  Future<void> _handleRejectState(UserSickLeaveEvent event, Emitter<UserSickLeaveState> emit) async {
    try {
      final bool result = await planningApi.reject(event.pk!);
      emit(UserSickLeaveRejectedState(result: result));
    } catch (e) {
      emit(UserSickLeaveErrorState(message: e.toString()));
    }
  }
}
