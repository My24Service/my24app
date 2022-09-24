import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/quotation/api/quotation_api.dart';
import 'package:my24app/quotation/blocs/part_states.dart';
import 'package:my24app/quotation/models/models.dart';

enum QuotationPartEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
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
      else if (event.status == QuotationPartEventStatus.FETCH_ALL) {
        await _handleFetchPartsState(event, emit);
      }
      else if (event.status == QuotationPartEventStatus.FETCH_DETAIL) {
        await _handleFetchPartDetailState(event, emit);
      }
      else if (event.status == QuotationPartEventStatus.INSERT) {
        await _handleInsertPartState(event, emit);
      }
      else if (event.status == QuotationPartEventStatus.EDIT) {
        await _handleEditPartState(event, emit);
      }
      else if (event.status == QuotationPartEventStatus.DELETE) {
        await _handleDeletePartState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(QuotationPartEvent event, Emitter<QuotationPartState> emit) {
    emit(QuotationPartLoadingState());
  }

  Future<void> _handleFetchPartsState(QuotationPartEvent event, Emitter<QuotationPartState> emit) async {
    try {
      final QuotationParts parts = await localQuotationApi.fetchQuotationParts(event.quotationPk);
      emit(QuotationPartsLoadedState(parts: parts));
    } catch(e) {
      emit(QuotationPartErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchPartDetailState(QuotationPartEvent event, Emitter<QuotationPartState> emit) async {
    try {
      final QuotationPart part = await localQuotationApi.fetchQuotationPart(event.pk);
      emit(QuotationPartLoadedState(part: part));
    } catch(e) {
      emit(QuotationPartErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertPartState(QuotationPartEvent event, Emitter<QuotationPartState> emit) async {
    try {
      final QuotationPart part = await localQuotationApi.insertQuotationPart(event.quotationPk, event.part);
      emit(QuotationPartInsertedState(part: part));
    } catch(e) {
      emit(QuotationPartErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditPartState(QuotationPartEvent event, Emitter<QuotationPartState> emit) async {
    try {
      final bool result = await localQuotationApi.editQuotationPart(event.pk, event.part);
      emit(QuotationPartEditedState(result: result));
    } catch(e) {
      emit(QuotationPartErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeletePartState(QuotationPartEvent event, Emitter<QuotationPartState> emit) async {
    try {
      final bool result = await localQuotationApi.deleteQuotationPart(event.value);
      emit(QuotationPartDeletedState(result: result));
    } catch(e) {
      emit(QuotationPartErrorState(message: e.toString()));
    }
  }
}
