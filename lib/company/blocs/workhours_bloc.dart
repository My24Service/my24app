import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/company/api/company_api.dart';
import 'package:my24app/company/blocs/workhours_states.dart';
import 'package:my24app/company/models/models.dart';

enum UserWorkHoursEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  NEW,
  INSERT,
  EDIT,
  DELETE,
}

class UserWorkHoursEvent {
  final UserWorkHoursEventStatus status;
  final int pk;
  final UserWorkHours hours;
  final DateTime startDate;

  const UserWorkHoursEvent({
    this.status,
    this.pk,
    this.hours,
    this.startDate,
  });
}

class UserWorkHoursBloc extends Bloc<UserWorkHoursEvent, UserWorkHoursState> {
  CompanyApi localCompanyApi = companyApi;

  UserWorkHoursBloc() : super(UserWorkHoursInitialState()) {
    on<UserWorkHoursEvent>((event, emit) async {
      if (event.status == UserWorkHoursEventStatus.NEW) {
        _handleNewState(event, emit);
      }
      if (event.status == UserWorkHoursEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.FETCH_DETAIL) {
        await _handleFetchDetailState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.EDIT) {
        await _handleEditState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleNewState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) {
    emit(UserWorkHoursNewState());
  }

  void _handleDoAsyncState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) {
    emit(UserWorkHoursLoadingState());
  }

  Future<void> _handleFetchAllState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) async {
    try {
      final UserWorkHoursPaginated results = await localCompanyApi.fetchUserWorkHours(event.startDate);
      emit(UserWorkHoursLoadedState(results: results, startDate: event.startDate));
    } catch (e) {
      emit(UserWorkHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) async {
    try {
      final UserWorkHours hours = await localCompanyApi.fetchUserWorkHoursDetail(event.pk);
      emit(UserWorkHoursDetailLoadedState(hours: hours));
    } catch(e) {
      emit(UserWorkHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) async {
    try {
      final UserWorkHours hours = await localCompanyApi.insertUserWorkHours(event.hours);
      emit(UserWorkHoursInsertedState(hours: hours));
    } catch(e) {
      emit(UserWorkHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) async {
    try {
      final bool result = await localCompanyApi.editUserWorkHours(event.pk, event.hours);
      emit(UserWorkHoursEditedState(result: result));
    } catch(e) {
      emit(UserWorkHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) async {
    try {
      final bool result = await localCompanyApi.deleteUserWorkHours(event.pk);
      emit(UserWorkHoursDeletedState(result: result));
    } catch (e) {
      emit(UserWorkHoursErrorState(message: e.toString()));
    }
  }
}
