import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/company/blocs/leave_type_states.dart';
import 'package:my24app/company/models/leave_type/models.dart';
import 'package:my24app/company/models/leave_type/api.dart';

import '../models/leave_type/form_data.dart';

enum LeaveTypeEventStatus {
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

class LeaveTypeEvent {
  final LeaveTypeEventStatus? status;
  final int? pk;
  final LeaveType? leaveType;
  final LeaveTypeFormData? formData;
  final int? page;
  final String? query;

  const LeaveTypeEvent({
    this.status,
    this.pk,
    this.leaveType,
    this.formData,
    this.query,
    this.page
  });
}

class LeaveTypeBloc extends Bloc<LeaveTypeEvent, LeaveTypeState> {
  LeaveTypeApi api = LeaveTypeApi();

  LeaveTypeBloc() : super(LeaveTypeInitialState()) {
    on<LeaveTypeEvent>((event, emit) async {
      if (event.status == LeaveTypeEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == LeaveTypeEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == LeaveTypeEventStatus.FETCH_DETAIL) {
        await _handleFetchState(event, emit);
      }
      else if (event.status == LeaveTypeEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == LeaveTypeEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == LeaveTypeEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == LeaveTypeEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == LeaveTypeEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == LeaveTypeEventStatus.NEW) {
        _handleNewFormDataState(event, emit);
      }
      else if (event.status == LeaveTypeEventStatus.NEW_EMPTY) {
        _handleNewEmptyFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleUpdateFormDataState(LeaveTypeEvent event, Emitter<LeaveTypeState> emit) {
    emit(LeaveTypeLoadedState(formData: event.formData));
  }

  void _handleDoSearchState(LeaveTypeEvent event, Emitter<LeaveTypeState> emit) {
    emit(LeaveTypeSearchState());
  }

  void _handleNewFormDataState(LeaveTypeEvent event, Emitter<LeaveTypeState> emit) {
    emit(LeaveTypeNewState(
        formData: LeaveTypeFormData.createEmpty()
    ));
  }

  void _handleNewEmptyFormDataState(LeaveTypeEvent event, Emitter<LeaveTypeState> emit) {
    emit(LeaveTypeNewState(
        formData: LeaveTypeFormData.createEmpty()
    ));
  }

  void _handleDoAsyncState(LeaveTypeEvent event, Emitter<LeaveTypeState> emit) {
    emit(LeaveTypeLoadingState());
  }

  Future<void> _handleFetchAllState(LeaveTypeEvent event, Emitter<LeaveTypeState> emit) async {
    try {
      final LeaveTypes leaveTypes = await api.list(
          filters: {
            'q': event.query,
            'page': event.page
          });
      emit(LeaveTypesLoadedState(leaveTypes: leaveTypes));
    } catch(e) {
      emit(LeaveTypeErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(LeaveTypeEvent event, Emitter<LeaveTypeState> emit) async {
    try {
      final LeaveType leaveType = await api.detail(event.pk!);
      emit(LeaveTypeLoadedState(
          formData: LeaveTypeFormData.createFromModel(leaveType)
      ));
    } catch(e) {
      emit(LeaveTypeErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(LeaveTypeEvent event, Emitter<LeaveTypeState> emit) async {
    try {
      final LeaveType leaveType = await api.insert(event.leaveType!);
      emit(LeaveTypeInsertedState(leaveType: leaveType));
    } catch(e) {
      emit(LeaveTypeErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(LeaveTypeEvent event, Emitter<LeaveTypeState> emit) async {
    try {
      final LeaveType leaveType = await api.update(event.pk!, event.leaveType!);
      emit(LeaveTypeUpdatedState(leaveType: leaveType));
    } catch(e) {
      emit(LeaveTypeErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(LeaveTypeEvent event, Emitter<LeaveTypeState> emit) async {
    try {
      final bool result = await api.delete(event.pk!);
      emit(LeaveTypeDeletedState(result: result));
    } catch(e) {
      emit(LeaveTypeErrorState(message: e.toString()));
    }
  }
}
