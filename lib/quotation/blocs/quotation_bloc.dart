import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/customer/models/api.dart';
import 'package:my24app/quotation/models/quotation/api.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/models/quotation/models.dart';
import 'package:my24app/quotation/models/quotation/form_data.dart';

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
  NEW,
  UPDATE_FORM_DATA,
  UPDATE
}

enum QuotationListTab {
  All,
  PRELIMINARY,
}

class QuotationEvent {
  final QuotationEventStatus? status;
  final Quotation? quotation;
  final QuotationFormData? formData;
  final int? pk;
  final dynamic value;
  final int? page;
  final String? query;
  final QuotationListTab? tab;

  const QuotationEvent(
      {this.status,
      this.quotation,
      this.pk,
      this.value,
      this.page,
      this.query,
      this.formData,
      this.tab});
}

class QuotationBloc extends Bloc<QuotationEvent, QuotationState> {
  QuotationApi localQuotationApi = QuotationApi();
  CustomerApi customerApi = CustomerApi();

  QuotationBloc() : super(QuotationInitialState()) {
    on<QuotationEvent>((event, emit) async {
      // generic
      if (event.status == QuotationEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      // quotations
      else if (event.status == QuotationEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      } else if (event.status == QuotationEventStatus.DO_REFRESH) {
        _handleDoRefreshState(event, emit);
      } else if (event.status == QuotationEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      } else if (event.status == QuotationEventStatus.FETCH_DETAIL) {
        await _handleFetchDetailState(event, emit);
      } else if (event.status == QuotationEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      } else if (event.status == QuotationEventStatus.EDIT) {
        await _handleEditState(event, emit);
      } else if (event.status == QuotationEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      } else if (event.status == QuotationEventStatus.FETCH_UNACCEPTED) {
        await _handleFetchUnAcceptedState(event, emit);
      } else if (event.status == QuotationEventStatus.FETCH_PRELIMINARY) {
        await _handleFetchPreliminaryState(event, emit);
      } else if (event.status == QuotationEventStatus.NEW) {
        await _handleNewFormDataState(event, emit);
      } else if (event.status == QuotationEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      } else if (event.status == QuotationEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
    }, transformer: sequential());
  }

  void _handleUpdateFormDataState(
      QuotationEvent event, Emitter<QuotationState> emit) {
    emit(QuotationUpdateState(formData: event.formData));
  }

  void _handleDoAsyncState(QuotationEvent event, Emitter<QuotationState> emit) {
    emit(QuotationLoadingState());
  }

  void _handleDoSearchState(
      QuotationEvent event, Emitter<QuotationState> emit) {
    emit(QuotationSearchState());
  }

  void _handleDoRefreshState(
      QuotationEvent event, Emitter<QuotationState> emit) {
    emit(QuotationRefreshState());
  }

  Future<void> _handleFetchAllState(
      QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotations quotations = await localQuotationApi
          .list(filters: {'q': event.query, 'page': event.page});
      emit(QuotationsLoadedState(quotations: quotations, query: event.query));
    } catch (e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailState(
      QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotation quotation = await localQuotationApi.detail(event.pk!);
      emit(QuotationLoadedState(quotation: quotation));
    } catch (e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchUnAcceptedState(
      QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotations quotations =
          await localQuotationApi.fetchUnAcceptedQuotations();
      emit(QuotationsUnacceptedLoadedState(quotations: quotations));
    } catch (e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchPreliminaryState(
      QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotations quotations = await localQuotationApi
          .fetchPreliminaryQuotations(
              filters: {'q': event.query, 'page': event.page});
      emit(QuotationsPreliminaryLoadedState(
          quotations: quotations, query: event.query));
    } catch (e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(
      QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotation? quotation =
          await localQuotationApi.insert(event.quotation!);

      emit(QuotationInsertedState(
          formData: QuotationFormData.createFromModel(quotation!)));
    } catch (e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(
      QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotation result =
          await localQuotationApi.update(event.pk!, event.quotation!);
      emit(QuotationEditedState(result: result));
    } catch (e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(
      QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final bool result = await localQuotationApi.delete(event.pk!);
      emit(QuotationDeletedState(result: result));
    } catch (e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleNewFormDataState(
      QuotationEvent event, Emitter<QuotationState> emit) async {
    QuotationFormData quotationFormData = QuotationFormData.createEmpty();

    emit(QuotationNewState(formData: quotationFormData));
  }
}
