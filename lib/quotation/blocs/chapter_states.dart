import 'package:equatable/equatable.dart';

import 'package:my24app/quotation/models/chapter/models.dart';
import 'package:my24app/quotation/models/chapter/form_data.dart';

abstract class ChapterState extends Equatable {}

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
  List<Object?> get props => [chapters, query];
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
