import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/quotation/api/quotation_api.dart';
import 'package:my24app/quotation/blocs/image_states.dart';
import 'package:my24app/quotation/models/models.dart';

enum ImageEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  DELETE,
}

class ImageEvent {
  final ImageEventStatus status;
  final int quotationPartPk;
  final dynamic value;

  const ImageEvent({this.value, this.quotationPartPk, this.status});
}

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  QuotationApi localQuotationApi = quotationApi;

  ImageBloc() : super(ImageInitialState()) {
    on<ImageEvent>((event, emit) async {
      if (event.status == ImageEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == ImageEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == ImageEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(ImageEvent event, Emitter<ImageState> emit) {
    emit(ImageLoadingState());
  }

  Future<void> _handleFetchAllState(ImageEvent event, Emitter<ImageState> emit) async {
    try {
      final QuotationPartImages images = await localQuotationApi.fetchQuotationPartImages(event.quotationPartPk);
      emit(ImagesLoadedState(images: images));
    } catch (e) {
      emit(ImageErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(ImageEvent event, Emitter<ImageState> emit) async {
    try {
      final bool result = await localQuotationApi.deleteQuotationImage(event.value);
      emit(ImageDeletedState(result: result));
    } catch (e) {
      emit(ImageErrorState(message: e.toString()));
    }
  }
}
