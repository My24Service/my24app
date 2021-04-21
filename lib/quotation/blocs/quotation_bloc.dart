import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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
  QuotationBloc(QuotationState initialState) : super(initialState);

  @override
  Stream<QuotationState> mapEventToState(event) async* {
    if (event.status == QuotationEventStatus.DO_ASYNC) {
      yield QuotationLoadingState();
    }

    if (event.status == QuotationEventStatus.DO_REFRESH) {
      yield QuotationRefreshState();
    }

    if (event.status == QuotationEventStatus.FETCH_ALL) {
      try {
        final Quotations quotations = await localQuotationApi.fetchQuotations(
            query: event.query,
            page: event.page
        );
        yield QuotationsLoadedState(quotations: quotations, query: event.query);
      } catch(e) {
        yield QuotationErrorState(message: e.toString());
      }
    }

    if (event.status == QuotationEventStatus.FETCH_UNACCEPTED) {
      try {
        final Quotations quotations = await localQuotationApi.fetchUncceptedQuotations();
        yield QuotationsUnacceptedLoadedState(quotations: quotations);
      } catch(e) {
        yield QuotationErrorState(message: e.toString());
      }
    }

    if (event.status == QuotationEventStatus.DELETE) {
      try {
        final bool result = await localQuotationApi.deleteQuotation(event.value);
        yield QuotationDeletedState(result: result);
      } catch(e) {
        yield QuotationErrorState(message: e.toString());
      }
    }

    if (event.status == QuotationEventStatus.ACCEPT) {
      try {
        final bool result = await localQuotationApi.acceptQuotation(event.value);
        yield QuotationAcceptedState(result: result);
      } catch(e) {
        yield QuotationErrorState(message: e.toString());
      }
    }
  }
}
