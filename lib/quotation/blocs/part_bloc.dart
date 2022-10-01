import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/quotation/api/quotation_api.dart';
import 'package:my24app/quotation/blocs/part_states.dart';
import 'package:my24app/quotation/models/models.dart';

enum QuotationPartEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  NEW,
  INSERT,
  EDIT,
  DELETE,
}

class QuotationPartEvent {
  final QuotationPartEventStatus status;
  final int pk;
  final int quotationPk;
  final QuotationPart part;
  final dynamic value;

  const QuotationPartEvent({
    this.status,
    this.pk,
    this.quotationPk,
    this.part,
    this.value,
  });
}

class QuotationPartBloc extends Bloc<QuotationPartEvent, QuotationPartState> {
  QuotationApi localQuotationApi = quotationApi;

  QuotationPartBloc() : super(QuotationPartInitialState()) {
    on<QuotationPartEvent>((event, emit) async {
      if (event.status == QuotationPartEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == QuotationPartEventStatus.NEW) {
        _handleNewState(event, emit);
      }
      else if (event.status == QuotationPartEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == QuotationPartEventStatus.FETCH_DETAIL) {
        await _handleFetchDetailState(event, emit);
      }
      else if (event.status == QuotationPartEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == QuotationPartEventStatus.EDIT) {
        await _handleEditState(event, emit);
      }
      else if (event.status == QuotationPartEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(QuotationPartEvent event, Emitter<QuotationPartState> emit) {
    emit(QuotationPartLoadingState());
  }

  void _handleNewState(QuotationPartEvent event, Emitter<QuotationPartState> emit) {
    emit(QuotationPartNewState());
  }

  Future<void> _handleFetchAllState(QuotationPartEvent event, Emitter<QuotationPartState> emit) async {
    try {
      final List<QuotationPart> result = await localQuotationApi.fetchQuotationParts(event.quotationPk);
      emit(QuotationPartsLoadedState(result: result));
    } catch(e) {
      emit(QuotationPartErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailState(QuotationPartEvent event, Emitter<QuotationPartState> emit) async {
    try {
      final QuotationPart part = await localQuotationApi.fetchQuotationPart(event.pk);
      emit(QuotationPartLoadedState(part: part));
    } catch(e) {
      emit(QuotationPartErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(QuotationPartEvent event, Emitter<QuotationPartState> emit) async {
    try {
      final QuotationPart part = await localQuotationApi.insertQuotationPart(event.part);
      emit(QuotationPartInsertedState(part: part));
    } catch(e) {
      emit(QuotationPartErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(QuotationPartEvent event, Emitter<QuotationPartState> emit) async {
    try {
      final bool result = await localQuotationApi.editQuotationPart(event.pk, event.part);
      emit(QuotationPartEditedState(result: result, quotationPartPk: event.pk));
    } catch(e) {
      emit(QuotationPartErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(QuotationPartEvent event, Emitter<QuotationPartState> emit) async {
    try {
      final bool result = await localQuotationApi.deleteQuotationPart(event.value);
      emit(QuotationPartDeletedState(result: result));
    } catch(e) {
      emit(QuotationPartErrorState(message: e.toString()));
    }
  }
}
