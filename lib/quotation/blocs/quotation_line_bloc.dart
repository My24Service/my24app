import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/quotation/models/quotation_line/api.dart';
import 'package:my24app/quotation/blocs/quotation_line_states.dart';
import 'package:my24app/quotation/models/quotation_line/models.dart';
import 'package:my24app/quotation/models/quotation_line/form_data.dart';

enum QuotationLineEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  INSERT,
  DELETE,
  NEW,
  UPDATE_FORM,
}

class QuotationLineEvent {
  final QuotationLineEventStatus? status;
  final QuotationLine? quotationLine;
  final QuotationLineFormData? formData;
  final int? pk;
  final int? page;
  final String? query;
  final int? quotationId;
  final int? chapterId;

  const QuotationLineEvent(
      {this.status,
      this.quotationLine,
      this.pk,
      this.page,
      this.query,
      this.formData,
      this.quotationId,
      this.chapterId});
}

class QuotationLineBloc extends Bloc<QuotationLineEvent, QuotationLineState> {
  QuotationLineApi quotationLineApi = QuotationLineApi();

  QuotationLineBloc() : super(QuotationLineInitialState()) {
    on<QuotationLineEvent>((event, emit) async {
      if (event.status == QuotationLineEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      } else if (event.status == QuotationLineEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      } else if (event.status == QuotationLineEventStatus.UPDATE_FORM) {
        emit(QuotationLinesLoadedState());
      } else if (event.status == QuotationLineEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
    }, transformer: sequential());
  }

  void _handleDoAsyncState(
      QuotationLineEvent event, Emitter<QuotationLineState> emit) {
    emit(QuotationLineLoadingState());
  }

  Future<void> _handleFetchAllState(
      QuotationLineEvent event, Emitter<QuotationLineState> emit) async {
    try {
      final QuotationLines quotationLines =
          await quotationLineApi.list(filters: {
        'q': event.query,
        'page': event.page,
        'quotation': event.quotationId,
        'chapter': event.chapterId,
      });
      emit(QuotationLinesLoadedState(
          quotationLines: quotationLines, query: event.query));
    } catch (e) {
      emit(QuotationLineErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(
      QuotationLineEvent event, Emitter<QuotationLineState> emit) async {
    try {
      final QuotationLine? quotationLine =
          await quotationLineApi.insert(event.quotationLine!);

      emit(QuotationLineInsertedState(quotationLine: quotationLine));
    } catch (e) {
      emit(QuotationLineErrorState(message: e.toString()));
    }
  }
}
