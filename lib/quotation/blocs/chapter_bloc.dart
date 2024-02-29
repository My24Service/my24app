import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/quotation/models/chapter/api.dart';
import 'package:my24app/quotation/blocs/chapter_states.dart';
import 'package:my24app/quotation/models/chapter/models.dart';
import 'package:my24app/quotation/models/chapter/form_data.dart';

enum ChapterEventStatus { DO_ASYNC, FETCH_ALL, INSERT, DELETE, NEW, CANCEL }

class ChapterEvent {
  final ChapterEventStatus? status;
  final Chapter? chapter;
  final ChapterFormData? formData;
  final int? pk;
  final dynamic value;
  final int? page;
  final String? query;
  final int? quotationId;

  const ChapterEvent(
      {this.status,
      this.chapter,
      this.pk,
      this.value,
      this.page,
      this.query,
      this.formData,
      this.quotationId});
}

class ChapterBloc extends Bloc<ChapterEvent, ChapterState> {
  ChapterApi chapterApi = ChapterApi();

  ChapterBloc() : super(ChapterState.init()) {
    on<ChapterEvent>((event, emit) async {
      if (event.status == ChapterEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      } else if (event.status == ChapterEventStatus.NEW) {
        _handleNewChapter(event, emit);
      } else if (event.status == ChapterEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      } else if (event.status == ChapterEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      } else if (event.status == ChapterEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      } else if (event.status == ChapterEventStatus.CANCEL) {
        emit(ChaptersLoadedState());
      }
    }, transformer: sequential());
  }

  void _handleDoAsyncState(ChapterEvent event, Emitter<ChapterState> emit) {
    emit(ChapterLoadingState());
  }

  void _handleNewChapter(ChapterEvent event, Emitter<ChapterState> emit) {
    ChapterFormData chapterFormData = ChapterFormData.createEmpty();

    emit(ChapterNewState(formData: chapterFormData));
  }

  Future<void> _handleFetchAllState(
      ChapterEvent event, Emitter<ChapterState> emit) async {
    try {
      final ChapterForms chapterForms;
      final Chapters chapters = await chapterApi.list(filters: {
        'q': event.query,
        'page': event.page,
        'quotation': event.quotationId
      });
      chapterForms = ChapterForms(chapters: chapters.results);
      emit(ChapterState.success(chapterForms));
      //emit(ChaptersLoadedState(chapters: chapters, query: event.query));
    } catch (e) {
      emit(ChapterState.error(e.toString()));
      //emit(ChapterErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(
      ChapterEvent event, Emitter<ChapterState> emit) async {
    try {
      final Chapter? chapter = await chapterApi.insert(event.chapter!);

      emit(ChapterInsertedState(chapter: chapter));
    } catch (e) {
      emit(ChapterErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(
      ChapterEvent event, Emitter<ChapterState> emit) async {
    try {
      final bool result = await chapterApi.delete(event.pk!);
      emit(ChapterDeletedState(result: result));
    } catch (e) {
      emit(ChapterErrorState(message: e.toString()));
    }
  }
}
