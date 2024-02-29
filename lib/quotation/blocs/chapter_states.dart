import 'package:equatable/equatable.dart';

import 'package:my24app/quotation/models/chapter/models.dart';
import 'package:my24app/quotation/models/chapter/form_data.dart';

enum ChapterStatus { loading, success, error }

class ChapterState extends Equatable {
  final ChapterStatus? status;
  final ChapterForms? chapterForms;
  final String? message;

  ChapterState(
      {this.chapterForms, this.status = ChapterStatus.loading, this.message});

  factory ChapterState.init() {
    return ChapterState(chapterForms: ChapterForms());
  }

  factory ChapterState.loading() {
    return ChapterState();
  }

  factory ChapterState.success(ChapterForms chapterForms) {
    return ChapterState(
        chapterForms: chapterForms, status: ChapterStatus.success);
  }

  factory ChapterState.error(message) {
    return ChapterState(status: ChapterStatus.error, message: message);
  }

  @override
  List<Object?> get props => [chapterForms, status, message];
}

class ChapterInitialState extends ChapterState {
  @override
  List<Object> get props => [];
}

class ChapterLoadingState extends ChapterState {
  @override
  List<Object> get props => [];
}

class ChapterLoadedState extends ChapterState {
  final Chapter? chapter;
  final ChapterFormData? formData;

  ChapterLoadedState({this.chapter, this.formData});

  @override
  List<Object?> get props => [chapter, formData];
}

class ChapterErrorState extends ChapterState {
  final String? message;

  ChapterErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class ChaptersLoadedState extends ChapterState {
  final Chapters? chapters;
  final String? query;
  final int? page;

  ChaptersLoadedState({this.chapters, this.query, this.page});

  @override
  List<Object?> get props => [chapters, query, page];
}

class ChapterDeletedState extends ChapterState {
  final bool? result;

  ChapterDeletedState({this.result});

  @override
  List<Object?> get props => [result];
}

class ChapterInsertedState extends ChapterState {
  final Chapters? chapters;
  final Chapter? chapter;
  final ChapterFormData? formData;

  ChapterInsertedState({this.chapter, this.formData, this.chapters});

  @override
  List<Object?> get props => [chapter, formData];
}

class ChapterNewState extends ChapterState {
  final ChapterFormData? formData;

  ChapterNewState({this.formData});

  @override
  List<Object?> get props => [formData];
}
