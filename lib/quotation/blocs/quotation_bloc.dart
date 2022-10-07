import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/quotation/api/quotation_api.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/models/models.dart';

enum QuotationEventStatus {
  DO_ASYNC,
  DO_SEARCH,
  DO_REFRESH,
  FETCH_ALL,
  FETCH_UNACCEPTED,
  FETCH_PRELIMINARY,
  FETCH_DETAIL,
  INSERT,
  EDIT,
  DELETE,
  ACCEPT,
  MAKE_DEFINITIVE,
}

class QuotationEvent {
  final QuotationEventStatus status;
  final Quotation quotation;
  final int pk;
  final dynamic value;
  final int page;
  final String query;

  const QuotationEvent({
    this.status,
    this.quotation,
    this.pk,
    this.value,
    this.page,
    this.query
  });
}

class QuotationBloc extends Bloc<QuotationEvent, QuotationState> {
  QuotationApi localQuotationApi = quotationApi;

  QuotationBloc() : super(QuotationInitialState()) {
    on<QuotationEvent>((event, emit) async {
      // generic
      if (event.status == QuotationEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      // quotations
      else if (event.status == QuotationEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == QuotationEventStatus.DO_REFRESH) {
        _handleDoRefreshState(event, emit);
      }
      else if (event.status == QuotationEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == QuotationEventStatus.FETCH_DETAIL) {
        await _handleFetchDetailState(event, emit);
      }
      else if (event.status == QuotationEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == QuotationEventStatus.EDIT) {
        await _handleEditState(event, emit);
      }
      else if (event.status == QuotationEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == QuotationEventStatus.FETCH_UNACCEPTED) {
        await _handleFetchUnAcceptedState(event, emit);
      }
      else if (event.status == QuotationEventStatus.FETCH_PRELIMINARY) {
        await _handleFetchPreliminaryState(event, emit);
      }
      else if (event.status == QuotationEventStatus.ACCEPT) {
        await _handleAcceptState(event, emit);
      }
      else if (event.status == QuotationEventStatus.MAKE_DEFINITIVE) {
        await _handleSetDefinitiveState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(QuotationEvent event, Emitter<QuotationState> emit) {
    emit(QuotationLoadingState());
  }

  void _handleDoSearchState(QuotationEvent event, Emitter<QuotationState> emit) {
    emit(QuotationSearchState());
  }

  void _handleDoRefreshState(QuotationEvent event, Emitter<QuotationState> emit) {
    emit(QuotationRefreshState());
  }

  Future<void> _handleFetchAllState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotations quotations = await localQuotationApi.fetchQuotations(
          query: event.query,
          page: event.page
      );
      emit(QuotationsLoadedState(quotations: quotations, query: event.query));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotation quotation = await localQuotationApi.fetchQuotation(event.pk);
      emit(QuotationLoadedState(quotation: quotation));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnAcceptedState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotations quotations = await localQuotationApi.fetchUncceptedQuotations();
      emit(QuotationsUnacceptedLoadedState(quotations: quotations));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchPreliminaryState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotations quotations = await localQuotationApi.fetchPreliminaryQuotations();
      emit(QuotationsPreliminaryLoadedState(quotations: quotations));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotation quotation = await localQuotationApi.insertQuotation(event.quotation);
      emit(QuotationInsertedState(quotation: quotation));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final bool result = await localQuotationApi.editQuotation(event.pk, event.quotation);
      emit(QuotationEditedState(result: result));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final bool result = await localQuotationApi.deleteQuotation(event.value);
      emit(QuotationDeletedState(result: result));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleAcceptState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final bool result = await localQuotationApi.acceptQuotation(event.value);
      emit(QuotationAcceptedState(result: result));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleSetDefinitiveState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final bool result = await localQuotationApi.makeDefinitive(event.pk);
      emit(QuotationDefinitiveState(result: result));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

}
