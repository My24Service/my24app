import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/quotation/api/quotation_api.dart';
import 'package:my24app/quotation/blocs/line_states.dart';
import 'package:my24app/quotation/models/models.dart';

enum PartLineEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  INSERT,
  NEW,
  EDIT,
  DELETE,
}

class PartLineEvent {
  final PartLineEventStatus? status;
  final int? pk;
  final int? quotationPartPk;
  final QuotationPartLine? line;
  final dynamic value;

  const PartLineEvent({
    this.status,
    this.pk,
    this.quotationPartPk,
    this.line,
    this.value,
  });
}

class PartLineBloc extends Bloc<PartLineEvent, PartLineState> {
  QuotationApi localQuotationApi = quotationApi;

  PartLineBloc() : super(PartLineInitialState()) {
    on<PartLineEvent>((event, emit) async {
      if (event.status == PartLineEventStatus.NEW) {
        _handleNewState(event, emit);
      }
      if (event.status == PartLineEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == PartLineEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == PartLineEventStatus.FETCH_DETAIL) {
        await _handleFetchDetailState(event, emit);
      }
      else if (event.status == PartLineEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == PartLineEventStatus.EDIT) {
        await _handleEditState(event, emit);
      }
      else if (event.status == PartLineEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleNewState(PartLineEvent event, Emitter<PartLineState> emit) {
    emit(PartLineNewState());
  }

  void _handleDoAsyncState(PartLineEvent event, Emitter<PartLineState> emit) {
    emit(PartLineLoadingState());
  }

  Future<void> _handleFetchAllState(PartLineEvent event, Emitter<PartLineState> emit) async {
    try {
      final QuotationPartLines result = await localQuotationApi.fetchQuotationPartLines(event.quotationPartPk);
      emit(PartLinesLoadedState(result: result));
    } catch (e) {
      emit(PartLineErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailState(PartLineEvent event, Emitter<PartLineState> emit) async {
    try {
      final QuotationPartLine line = await localQuotationApi.fetchQuotationPartLine(event.pk);
      emit(PartLineLoadedState(line: line));
    } catch(e) {
      emit(PartLineErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(PartLineEvent event, Emitter<PartLineState> emit) async {
    try {
      final QuotationPartLine? line = await localQuotationApi.insertQuotationPartLine(event.line!);
      emit(PartLineInsertedState(line: line));
    } catch(e) {
      emit(PartLineErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(PartLineEvent event, Emitter<PartLineState> emit) async {
    try {
      final bool result = await localQuotationApi.editQuotationPartLine(event.pk, event.line!);
      emit(PartLineEditedState(result: result));
    } catch(e) {
      emit(PartLineErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(PartLineEvent event, Emitter<PartLineState> emit) async {
    try {
      final bool result = await localQuotationApi.deleteQuotationPartLine(event.pk);
      emit(PartLineDeletedState(result: result));
    } catch (e) {
      emit(PartLineErrorState(message: e.toString()));
    }
  }
}
