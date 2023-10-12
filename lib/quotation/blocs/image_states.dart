import 'package:equatable/equatable.dart';

import 'package:my24app/quotation/models/models.dart';

abstract class PartImageState extends Equatable {}

class PartImageInitialState extends PartImageState {
  @override
  List<Object> get props => [];
}

class PartImageNewState extends PartImageState {
  @override
  List<Object> get props => [];
}

class PartImageLoadingState extends PartImageState {
  @override
  List<Object> get props => [];
}

class PartImageErrorState extends PartImageState {
  final String? message;

  PartImageErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class PartImagesLoadedState extends PartImageState {
  final QuotationPartImages? images;

  PartImagesLoadedState({this.images});

  @override
  List<Object?> get props => [images];
}

class PartImageInsertedState extends PartImageState {
  final QuotationPartImage? image;

  PartImageInsertedState({this.image});

  @override
  List<Object?> get props => [image];
}

class PartImageEditedState extends PartImageState {
  final bool? result;

  PartImageEditedState({this.result});

  @override
  List<Object?> get props => [result];
}

class PartImageDeletedState extends PartImageState {
  final bool? result;

  PartImageDeletedState({this.result});

  @override
  List<Object?> get props => [result];
}

class PartImageLoadedState extends PartImageState {
  final QuotationPartImage? image;

  PartImageLoadedState({this.image});

  @override
  List<Object?> get props => [image];
}
