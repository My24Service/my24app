import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24app/quotation/models/chapter/models.dart';
import 'package:my24app/quotation/models/quotation_line/api.dart';
import 'package:my24app/quotation/blocs/quotation_line_states.dart';
import 'package:my24app/quotation/models/quotation_line/models.dart';
import 'package:my24app/quotation/models/quotation_line/form_data.dart';

enum QuotationLineEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  INSERT,
  DELETE,
  NEW_FORM,
  UPDATE_FORM,
}

class QuotationLineEvent {
  final QuotationLineEventStatus? status;
  final QuotationLine? quotationLine;
  final QuotationLineFormData? formData;
  final QuotationLineForms? quotationLineForms;
  final int? pk;
  final int? page;
  final String? query;
  final int? quotationId;
  final int? chapterId;
  final Map<GlobalKey<FormState>, QuotationLineFormData>?
      quotationLinesFormsMap;

  const QuotationLineEvent(
      {this.status,
      this.quotationLine,
      this.pk,
      this.page,
      this.query,
      this.formData,
      this.quotationId,
      this.chapterId,
      this.quotationLinesFormsMap,
      this.quotationLineForms});
}

class QuotationLineBloc extends Bloc<QuotationLineEvent, QuotationLineState> {
  QuotationLineApi quotationLineApi = QuotationLineApi();

  QuotationLineBloc() : super(QuotationLineState.init()) {
    on<QuotationLineEvent>((event, emit) async {
      if (event.status == QuotationLineEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      } else if (event.status == QuotationLineEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      } else if (event.status == QuotationLineEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      } else if (event.status == QuotationLineEventStatus.NEW_FORM ||
          event.status == QuotationLineEventStatus.UPDATE_FORM) {
        _handleNewFormState(event, emit);
      } else if (event.status == QuotationLineEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
    }, transformer: sequential());
  }

  void _handleDoAsyncState(
      QuotationLineEvent event, Emitter<QuotationLineState> emit) {
    emit(QuotationLineState.init());
  }

  Future<void> _handleFetchAllState(
      QuotationLineEvent event, Emitter<QuotationLineState> emit) async {
    try {
      final QuotationLineForms quotationLineForms;
      Map<String, dynamic> initialData = await coreUtils.getInitialDataPrefs();
      final QuotationLines quotationLines =
          await quotationLineApi.list(filters: {
        'q': event.query,
        'page': event.page,
        'quotation': event.quotationId,
        'chapter': event.chapterId,
      });

      quotationLineForms =
          QuotationLineForms(quotationLines: quotationLines.results);
      quotationLineForms.currency =
          initialData['memberInfo']['settings']['default_currency'];

      emit(QuotationLineState.success(quotationLineForms));
    } catch (e) {
      emit(QuotationLineState.error(e.toString()));
    }
  }

  Future<void> _handleInsertState(
      QuotationLineEvent event, Emitter<QuotationLineState> emit) async {
    try {
      final QuotationLine? quotationLine =
          await quotationLineApi.insert(event.quotationLine!);
      event.quotationLineForms!.quotationLines!.add(quotationLine!);
      emit(QuotationLineState.success(event.quotationLineForms!));
    } catch (e) {
      emit(QuotationLineState.error(e.toString()));
    }
  }

  void _handleNewFormState(
      QuotationLineEvent event, Emitter<QuotationLineState> emit) {
    emit(NewQuotationLinesFormState(
        quotationLinesFormsMap: event.quotationLinesFormsMap));
  }

  Future<void> _handleDeleteState(
      QuotationLineEvent event, Emitter<QuotationLineState> emit) async {
    try {
      await quotationLineApi.delete(event.pk!);
      emit(QuotationLineDeletedState());
    } catch (e) {
      emit(QuotationLineState.error(e.toString()));
    }
  }
}
