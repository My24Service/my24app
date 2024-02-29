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

class ChapterDeletedState extends ChapterState {
  @override
  List<Object?> get props => [];
}
