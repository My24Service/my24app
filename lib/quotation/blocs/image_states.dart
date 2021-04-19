import 'package:equatable/equatable.dart';

import 'package:my24app/quotation/models/models.dart';

abstract class ImageState extends Equatable {}

class ImageInitialState extends ImageState {
  @override
  List<Object> get props => [];
}

class ImageLoadingState extends ImageState {
  @override
  List<Object> get props => [];
}

class ImageErrorState extends ImageState {
  final String message;

  ImageErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class ImagesLoadedState extends ImageState {
  final QuotationImages images;

  ImagesLoadedState({this.images});

  @override
  List<Object> get props => [images];
}

class ImageDeletedState extends ImageState {
  final bool result;

  ImageDeletedState({this.result});

  @override
  List<Object> get props => [result];
}

class ImageInsertedState extends ImageState {
  final QuotationImage image;

  ImageInsertedState({this.image});

  @override
  List<Object> get props => [image];
}
