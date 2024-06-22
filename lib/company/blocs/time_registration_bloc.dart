import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:my24_flutter_core/utils.dart';

import 'package:my24app/company/models/time_registration/api.dart';
import 'package:my24app/company/blocs/time_registration_states.dart';
import 'package:my24app/company/models/time_registration/models.dart';

enum TimeRegistrationEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  SWITCH_MODE,
}

class TimeRegistrationEvent {
  final TimeRegistrationEventStatus? status;
  final int? userId;
  final TimeRegistration? timeRegistrationData;
  final DateTime? startDate;
  final String? mode;

  const TimeRegistrationEvent({
    this.status,
    this.userId,
    this.timeRegistrationData,
    this.startDate,
    this.mode,
  });
}

class TimeRegistrationBloc extends Bloc<TimeRegistrationEvent, TimeRegistrationState> {
  TimeRegistrationApi api = TimeRegistrationApi();

  TimeRegistrationBloc() : super(TimeRegistrationInitialState()) {
    on<TimeRegistrationEvent>((event, emit) async {
      if (event.status == TimeRegistrationEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == TimeRegistrationEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == TimeRegistrationEventStatus.SWITCH_MODE) {
        await _handleSwitchModeState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(TimeRegistrationEvent event, Emitter<TimeRegistrationState> emit) {
    emit(TimeRegistrationLoadingState());
  }

  Future<void> _handleFetchAllState(TimeRegistrationEvent event, Emitter<TimeRegistrationState> emit) async {
    // try {
      // /api/company/time-registration/?page=1&mode=week&user=77&start_date=2023-05-05
      // /api/company/time-registration/?page=1&mode=week&start_date=2023-05-05

      final String mode = event.mode == null ? 'week' : event.mode!;

      Map<String, dynamic> filters = {
        'mode': mode
      };

      if (event.userId != null) {
        filters['user'] = event.userId;
      }

      final DateTime startDate = event.startDate == null ? coreUtils.getMonday() : event.startDate!;

      final String startDateTxt = coreUtils.formatDate(startDate);
      filters['start_date'] = startDateTxt;

      final TimeRegistration timeRegistrationData = await api.list(filters: filters);
      emit(TimeRegistrationLoadedState(
          startDate: startDate,
          timeRegistrationData: timeRegistrationData,
          userId: event.userId,
          mode: mode
      ));
    // } catch(e) {
    //   emit(TimeRegistrationErrorState(message: e.toString()));
    // }
  }

  Future<void> _handleSwitchModeState(TimeRegistrationEvent event, Emitter<TimeRegistrationState> emit) async {
    // try {
    // /api/company/time-registration/?page=1&mode=week&user=77&start_date=2023-05-05
    // /api/company/time-registration/?page=1&mode=week&start_date=2023-05-05

    final String mode = event.mode == null ? 'week' : event.mode!;

    Map<String, dynamic> filters = {
      'mode': mode
    };

    if (event.userId != null) {
      filters['user'] = event.userId;
    }

    final DateTime startDate = event.startDate == null ? coreUtils.getMonday() : event.startDate!;

    final String startDateTxt = coreUtils.formatDate(startDate);
    filters['start_date'] = startDateTxt;

    final TimeRegistration timeRegistrationData = await api.list(filters: filters);
    emit(TimeRegistrationModeSwitchState(
        startDate: startDate,
        timeRegistrationData: timeRegistrationData,
        userId: event.userId,
        mode: event.mode
    ));
    // } catch(e) {
    //   emit(TimeRegistrationErrorState(message: e.toString()));
    // }
  }

}
