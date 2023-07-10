import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/company/models/leavehours/api.dart';
import 'package:my24app/company/blocs/leavehours_states.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/company/models/leavehours/form_data.dart';
import '../models/leave_type/api.dart';
import '../models/leave_type/models.dart';

enum UserLeaveHoursEventStatus {
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

class UserLeaveHoursEvent {
  final UserLeaveHoursEventStatus? status;
  final int? pk;
  final UserLeaveHours? leaveHours;
  final UserLeaveHoursFormData? formData;
  final int? page;
  final String? query;
  final bool? isPlanning;
  final bool? isFetchingTotals;

  const UserLeaveHoursEvent({
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

class UserLeaveHoursBloc extends Bloc<UserLeaveHoursEvent, UserLeaveHoursState> {
  UserLeaveHoursApi api = UserLeaveHoursApi();
  UserLeaveHoursPlanningApi planningApi = UserLeaveHoursPlanningApi();
  LeaveTypeApi leaveTypeApi = LeaveTypeApi();

  UserLeaveHoursBloc() : super(UserLeaveHoursInitialState()) {
    on<UserLeaveHoursEvent>((event, emit) async {
      if (event.status == UserLeaveHoursEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.FETCH_UNACCEPTED) {
        await _handleFetchUnacceptedState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.FETCH_DETAIL) {
        await _handleFetchState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.GET_TOTALS) {
        await _handleGetTotalsState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.DO_GET_TOTALS) {
        _handleDoGetTotalsState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.NEW) {
        await _handleNewFormDataState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.ACCEPT) {
        await _handleAcceptState(event, emit);
      }
      else if (event.status == UserLeaveHoursEventStatus.REJECT) {
        await _handleRejectState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleUpdateFormDataState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) {
    emit(UserLeaveHoursLoadedState(
        formData: event.formData,
        isFetchingTotals: false
    ));
  }

  Future<void> _handleGetTotalsState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) async {
    UserLeaveHours hours = event.formData!.toModel();
    LeaveHoursData totals = event.isPlanning! ? await planningApi.getTotals(hours) : await api.getTotals(hours);
    event.formData!.totalHours = "${totals.totalHours}";
    event.formData!.totalMinutes = totals.totalMinutes! < 10 ? "0${totals.totalMinutes}" : "${totals.totalMinutes}";
    print("emitting UserLeaveHoursLoadedState, total hours: ${totals.totalHours}");
    emit(TotalsLoadedState(
        formData: event.formData,
        totals: totals
    ));
  }

  void _handleDoSearchState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) {
    emit(UserLeaveHoursSearchState());
  }

  Future<void> _handleNewFormDataState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) async {
    final LeaveTypes leaveTypes = await leaveTypeApi.fetchLeaveTypesForSelect();

    // load initial totals
    UserLeaveHoursFormData formData = UserLeaveHoursFormData.createEmpty(leaveTypes);
    UserLeaveHours hours = formData.toModel();
    LeaveHoursData totals = event.isPlanning! ? await planningApi.getTotals(hours) : await api.getTotals(hours);
    formData.totalHours = "${totals.totalHours}";
    formData.totalMinutes = totals.totalMinutes! < 10 ? "0${totals.totalMinutes}" : "${totals.totalMinutes}";

    emit(UserLeaveHoursNewState(
        formData: formData,
        isFetchingTotals: false
    ));
  }

  void _handleDoGetTotalsState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) {
    emit(UserLeaveHoursTotalsLoadingState(
      formData: event.formData,
      isFetchingTotals: true
    ));
  }

  void _handleDoAsyncState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) {
    emit(UserLeaveHoursLoadingState());
  }

  Future<void> _handleFetchAllState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) async {
    try {
      Map<String, dynamic> filters = {
        'q': event.query,
        'page': event.page
      };

      final UserLeaveHoursPaginated leaveHoursPaginated = event.isPlanning! ? await planningApi.list(filters: filters) : await api.list(filters: filters);
      emit(UserLeaveHoursPaginatedLoadedState(
          leaveHoursPaginated: leaveHoursPaginated
      ));
    } catch(e) {
      emit(UserLeaveHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnacceptedState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) async {
    try {
      final UserLeaveHoursPaginated userLeaveHoursPaginated = event.isPlanning! ? await planningApi.fetchUnaccepted(
          page: event.page,
          query: event.query
      ) : await api.fetchUnaccepted(
          page: event.page,
          query: event.query
      );
      emit(UserLeaveHoursUnacceptedPaginatedLoadedState(
          leaveHoursPaginated: userLeaveHoursPaginated,
          query: event.query, page: event.page));
    } catch (e) {
      emit(UserLeaveHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) async {
    try {
      final UserLeaveHours leaveHours = event.isPlanning! ? await planningApi.detail(event.pk!) : await api.detail(event.pk!);
      final LeaveTypes leaveTypes = await leaveTypeApi.fetchLeaveTypesForSelect();
      emit(UserLeaveHoursLoadedState(
          formData: UserLeaveHoursFormData.createFromModel(leaveTypes, leaveHours),
          isFetchingTotals: false
      ));
    } catch(e) {
      emit(UserLeaveHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) async {
    try {
      final UserLeaveHours leaveHours = event.isPlanning! ? await planningApi.insert(event.leaveHours!) : await api.insert(event.leaveHours!);
      emit(UserLeaveHoursInsertedState(leaveHours: leaveHours));
    } catch(e) {
      emit(UserLeaveHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) async {
    try {
      print("CALLING API");
      final UserLeaveHours leaveHours = event.isPlanning! ? await planningApi.update(event.pk!, event.leaveHours!) : await api.update(event.pk!, event.leaveHours!);
      emit(UserLeaveHoursUpdatedState(leaveHours: leaveHours));
    } catch(e) {
      emit(UserLeaveHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) async {
    try {
      final bool result = event.isPlanning! ? await planningApi.delete(event.pk!) : await api.delete(event.pk!);
      emit(UserLeaveHoursDeletedState(result: result));
    } catch(e) {
      emit(UserLeaveHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleAcceptState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) async {
    try {
      final bool result = await planningApi.accept(event.pk!);
      emit(UserLeaveHoursAcceptedState(result: result));
    } catch (e) {
      emit(UserLeaveHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleRejectState(UserLeaveHoursEvent event, Emitter<UserLeaveHoursState> emit) async {
    try {
      final bool result = await planningApi.reject(event.pk!);
      emit(UserLeaveHoursRejectedState(result: result));
    } catch (e) {
      emit(UserLeaveHoursErrorState(message: e.toString()));
    }
  }
}
