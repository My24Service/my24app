import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/order/blocs/document_states.dart';
import 'package:my24app/order/models/document/models.dart';

import '../models/document/form_data.dart';
import '../models/document/api.dart';

enum OrderDocumentEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  DO_SEARCH,
  FETCH_DETAIL,
  NEW,
  NEW_EMPTY,
  DELETE,
  UPDATE,
  INSERT,
  UPDATE_FORM_DATA
}

class OrderDocumentEvent {
  final int pk;
  final int orderId;
  final OrderDocument document;
  final OrderDocumentFormData documentFormData;
  final OrderDocumentEventStatus status;
  final int page;
  final String query;

  const OrderDocumentEvent({
    this.pk,
    this.orderId,
    this.status,
    this.document,
    this.documentFormData,
    this.page,
    this.query
  });
}

class OrderDocumentBloc extends Bloc<OrderDocumentEvent, OrderDocumentState> {
  OrderDocumentApi api = OrderDocumentApi();

  OrderDocumentBloc() : super(OrderDocumentInitialState()) {
    on<OrderDocumentEvent>((event, emit) async {
      if (event.status == OrderDocumentEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == OrderDocumentEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == OrderDocumentEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == OrderDocumentEventStatus.FETCH_DETAIL) {
        await _handleFetchState(event, emit);
      }
      else if (event.status == OrderDocumentEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == OrderDocumentEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == OrderDocumentEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == OrderDocumentEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == OrderDocumentEventStatus.NEW) {
        _handleNewFormDataState(event, emit);
      }
      else if (event.status == OrderDocumentEventStatus.NEW_EMPTY) {
        _handleNewEmptyFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleUpdateFormDataState(OrderDocumentEvent event, Emitter<OrderDocumentState> emit) {
    emit(OrderDocumentLoadedState(documentFormData: event.documentFormData));
  }

  void _handleDoSearchState(OrderDocumentEvent event, Emitter<OrderDocumentState> emit) {
    emit(OrderDocumentSearchState());
  }

  void _handleNewFormDataState(OrderDocumentEvent event, Emitter<OrderDocumentState> emit) {
    emit(OrderDocumentNewState(
        fromEmpty: false,
        documentFormData: OrderDocumentFormData.createEmpty(event.orderId)
    ));
  }

  void _handleNewEmptyFormDataState(OrderDocumentEvent event, Emitter<OrderDocumentState> emit) {
    emit(OrderDocumentNewState(
        fromEmpty: true,
        documentFormData: OrderDocumentFormData.createEmpty(event.orderId)
    ));
  }

  void _handleDoAsyncState(OrderDocumentEvent event, Emitter<OrderDocumentState> emit) {
    emit(OrderDocumentLoadingState());
  }

  Future<void> _handleFetchAllState(OrderDocumentEvent event, Emitter<OrderDocumentState> emit) async {
    try {
      final OrderDocuments documents = await api.list(filters: {
        "order": event.orderId,
        'page': event.page,
        'q': event.query,
      });
      emit(OrderDocumentsLoadedState(
          documents: documents,
          query: event.query,
          page: event.page
      ));
    } catch(e) {
      emit(OrderDocumentErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(OrderDocumentEvent event, Emitter<OrderDocumentState> emit) async {
    try {
      final OrderDocument activity = await api.detail(event.pk);
      emit(OrderDocumentLoadedState(
          documentFormData: OrderDocumentFormData.createFromModel(activity)
      ));
    } catch(e) {
      emit(OrderDocumentErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(OrderDocumentEvent event, Emitter<OrderDocumentState> emit) async {
    try {
      final OrderDocument document = await api.insert(event.document);
      emit(OrderDocumentInsertedState(document: document));
    } catch(e) {
      emit(OrderDocumentErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(OrderDocumentEvent event, Emitter<OrderDocumentState> emit) async {
    try {
      final OrderDocument document = await api.update(event.pk, event.document);
      emit(OrderDocumentUpdatedState(document: document));
    } catch(e) {
      emit(OrderDocumentErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(OrderDocumentEvent event, Emitter<OrderDocumentState> emit) async {
    try {
      final bool result = await api.delete(event.pk);
      emit(OrderDocumentDeletedState(result: result));
    } catch(e) {
      print(e);
      emit(OrderDocumentErrorState(message: e.toString()));
    }
  }
}
