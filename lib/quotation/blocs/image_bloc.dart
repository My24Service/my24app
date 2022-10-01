import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/quotation/api/quotation_api.dart';
import 'package:my24app/quotation/blocs/image_states.dart';
import 'package:my24app/quotation/models/models.dart';

enum PartImageEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  NEW,
  INSERT,
  EDIT,
  DELETE,
}

class PartImageEvent {
  final PartImageEventStatus status;
  final int pk;
  final int quotationPartPk;
  final QuotationPartImage image;
  final dynamic value;

  const PartImageEvent({
    this.status,
    this.pk,
    this.quotationPartPk,
    this.image,
    this.value,
  });
}

class PartImageBloc extends Bloc<PartImageEvent, PartImageState> {
  QuotationApi localQuotationApi = quotationApi;

  PartImageBloc() : super(PartImageInitialState()) {
    on<PartImageEvent>((event, emit) async {
      if (event.status == PartImageEventStatus.NEW) {
        _handleNewState(event, emit);
      }
      if (event.status == PartImageEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == PartImageEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == PartImageEventStatus.FETCH_DETAIL) {
        await _handleFetchDetailState(event, emit);
      }
      else if (event.status == PartImageEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == PartImageEventStatus.EDIT) {
        await _handleEditState(event, emit);
      }
      else if (event.status == PartImageEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleNewState(PartImageEvent event, Emitter<PartImageState> emit) {
    emit(PartImageNewState());
  }

  void _handleDoAsyncState(PartImageEvent event, Emitter<PartImageState> emit) {
    emit(PartImageLoadingState());
  }

  Future<void> _handleFetchAllState(PartImageEvent event, Emitter<PartImageState> emit) async {
    try {
      final QuotationPartImages images = await localQuotationApi.fetchQuotationPartImages(event.quotationPartPk);
      emit(PartImagesLoadedState(images: images));
    } catch (e) {
      emit(PartImageErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailState(PartImageEvent event, Emitter<PartImageState> emit) async {
    try {
      final QuotationPartImage image = await localQuotationApi.fetchQuotationPartImage(event.pk);
      emit(PartImageLoadedState(image: image));
    } catch(e) {
      emit(PartImageErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(PartImageEvent event, Emitter<PartImageState> emit) async {
    try {
      final QuotationPartImage image = await localQuotationApi.insertQuotationPartImage(event.image);
      emit(PartImageInsertedState(image: image));
    } catch(e) {
      emit(PartImageErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(PartImageEvent event, Emitter<PartImageState> emit) async {
    try {
      final bool result = await localQuotationApi.editQuotationPartImage(event.pk, event.image);
      emit(PartImageEditedState(result: result));
    } catch(e) {
      emit(PartImageErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(PartImageEvent event, Emitter<PartImageState> emit) async {
    try {
      final bool result = await localQuotationApi.deleteQuotationPartImage(event.pk);
      emit(PartImageDeletedState(result: result));
    } catch (e) {
      emit(PartImageErrorState(message: e.toString()));
    }
  }
}
