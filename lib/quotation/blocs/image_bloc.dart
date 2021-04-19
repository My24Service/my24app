import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/quotation/api/quotation_api.dart';
import 'package:my24app/quotation/blocs/image_states.dart';
import 'package:my24app/quotation/models/models.dart';

enum ImageEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  DELETE,
  INSERT,
}

class ImageEvent {
  final ImageEventStatus status;
  final int quotationPk;
  final dynamic value;

  const ImageEvent({this.value, this.quotationPk, this.status});
}

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  QuotationApi localQuotationApi = quotationApi;

  ImageBloc(ImageState initialState) : super(initialState);

  @override
  Stream<ImageState> mapEventToState(event) async* {
    if (event.status == ImageEventStatus.DO_ASYNC) {
      yield ImageLoadingState();
    }

    if (event.status == ImageEventStatus.FETCH_ALL) {
      try {
        final QuotationImages images = await localQuotationApi.fetchQuotationImages(event.quotationPk);
        yield ImagesLoadedState(images: images);
      } catch (e) {
        yield ImageErrorState(message: e.toString());
      }
    }

    if (event.status == ImageEventStatus.DELETE) {
      try {
        final bool result = await localQuotationApi.deleteQuotationImage(event.value);
        yield ImageDeletedState(result: result);
      } catch (e) {
        yield ImageErrorState(message: e.toString());
      }
    }

    if (event.status == ImageEventStatus.INSERT) {
      try {
        final QuotationImage image = await localQuotationApi.insertQuotationImage(event.value, event.quotationPk);
        yield ImageInsertedState(image: image);
      } catch (e) {
        yield ImageErrorState(message: e.toString());
      }
    }
  }
}
