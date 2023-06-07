import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/company/models/workhours/api.dart';
import 'package:my24app/company/blocs/workhours_states.dart';
import 'package:my24app/company/models/workhours/models.dart';
import 'package:my24app/company/models/workhours/form_data.dart';

import '../models/project/api.dart';
import '../models/project/models.dart';

enum UserWorkHoursEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  DO_SEARCH,
  NEW,
  DELETE,
  UPDATE,
  INSERT,
  UPDATE_FORM_DATA
}

class UserWorkHoursEvent {
  final UserWorkHoursEventStatus? status;
  final int? pk;
  final UserWorkHours? workHours;
  final DateTime? startDate;
  final UserWorkHoursFormData? formData;
  final int? page;
  final String? query;

  const UserWorkHoursEvent({
    this.status,
    this.pk,
    this.workHours,
    this.startDate,
    this.formData,
    this.page,
    this.query
  });
}

class UserWorkHoursBloc extends Bloc<UserWorkHoursEvent, UserWorkHoursState> {
  UserWorkHoursApi api = UserWorkHoursApi();
  ProjectApi projectApi = ProjectApi();

  UserWorkHoursBloc() : super(UserWorkHoursInitialState()) {
    on<UserWorkHoursEvent>((event, emit) async {
      if (event.status == UserWorkHoursEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.FETCH_DETAIL) {
        await _handleFetchState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == UserWorkHoursEventStatus.NEW) {
        await _handleNewFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleUpdateFormDataState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) {
    emit(UserWorkHoursLoadedState(formData: event.formData));
  }

  void _handleDoSearchState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) {
    emit(UserWorkHoursSearchState());
  }

  Future<void> _handleNewFormDataState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) async {
    final Projects projects = await projectApi.fetchProjectsForSelect();
    emit(UserWorkHoursNewState(
        formData: UserWorkHoursFormData.createEmpty(projects)
    ));
  }

  void _handleDoAsyncState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) {
    emit(UserWorkHoursLoadingState());
  }

  Future<void> _handleFetchAllState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) async {
    try {
      Map<String, dynamic> filters = {
        'q': event.query,
        'page': event.page
      };

      if (event.startDate != null) {
        final String startDateTxt = utils.formatDate(event.startDate!);
        filters['start_date'] = startDateTxt;
      }

      final UserWorkHoursPaginated workHoursPaginated = await api.list(filters: filters);
      emit(UserWorkHoursPaginatedLoadedState(workHoursPaginated: workHoursPaginated));
    } catch(e) {
      emit(UserWorkHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) async {
    try {
      final UserWorkHours workHours = await api.detail(event.pk!);
      final Projects projects = await projectApi.fetchProjectsForSelect();
      emit(UserWorkHoursLoadedState(
          formData: UserWorkHoursFormData.createFromModel(projects, workHours)
      ));
    } catch(e) {
      emit(UserWorkHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) async {
    try {
      final UserWorkHours workHours = await api.insert(event.workHours!);
      emit(UserWorkHoursInsertedState(workHours: workHours));
    } catch(e) {
      emit(UserWorkHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) async {
    try {
      final UserWorkHours workHours = await api.update(event.pk!, event.workHours!);
      emit(UserWorkHoursUpdatedState(workHours: workHours));
    } catch(e) {
      emit(UserWorkHoursErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(UserWorkHoursEvent event, Emitter<UserWorkHoursState> emit) async {
    try {
      final bool result = await api.delete(event.pk!);
      emit(UserWorkHoursDeletedState(result: result));
    } catch(e) {
      print(e);
      emit(UserWorkHoursErrorState(message: e.toString()));
    }
  }
}
