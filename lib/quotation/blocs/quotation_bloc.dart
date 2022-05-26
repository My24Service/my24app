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
  DELETE,
  ACCEPT
}

class QuotationEvent {
  final QuotationEventStatus status;
  final int orderPk;
  final dynamic value;
  final int page;
  final String query;

  const QuotationEvent({this.value, this.orderPk, this.status, this.page, this.query});
}

class QuotationBloc extends Bloc<QuotationEvent, QuotationState> {
  QuotationApi localQuotationApi = quotationApi;

  QuotationBloc() : super(QuotationInitialState()) {
    on<QuotationEvent>((event, emit) async {
      if (event.status == QuotationEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == QuotationEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == QuotationEventStatus.DO_REFRESH) {
        _handleDoRefreshState(event, emit);
      }
      else if (event.status == QuotationEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == QuotationEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == QuotationEventStatus.FETCH_UNACCEPTED) {
        await _handleUnAcceptedState(event, emit);
      }
      else if (event.status == QuotationEventStatus.ACCEPT) {
        await _handleAcceptState(event, emit);
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

  Future<void> _handleUnAcceptedState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotations quotations = await localQuotationApi.fetchUncceptedQuotations();
      emit(QuotationsUnacceptedLoadedState(quotations: quotations));
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

}
