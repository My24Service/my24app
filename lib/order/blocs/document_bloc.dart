import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/order/api/document_api.dart';
import 'package:my24app/order/blocs/document_states.dart';
import 'package:my24app/order/models/document/models.dart';

enum DocumentEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  DELETE,
}

class DocumentEvent {
  final DocumentEventStatus status;
  final int orderPk;
  final dynamic value;

  const DocumentEvent({this.value, this.orderPk, this.status});
}

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  DocumentApi localDocumentApi = documentApi;

  DocumentBloc() : super(DocumentInitialState()) {
    on<DocumentEvent>((event, emit) async {
      if (event.status == DocumentEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == DocumentEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == DocumentEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(DocumentEvent event, Emitter<DocumentState> emit) {
    emit(DocumentLoadingState());
  }

  Future<void> _handleFetchAllState(DocumentEvent event, Emitter<DocumentState> emit) async {
    try {
      final OrderDocuments documents = await localDocumentApi.fetchOrderDocuments(event.orderPk);
      emit(DocumentsLoadedState(documents: documents));
    } catch(e) {
      emit(DocumentErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(DocumentEvent event, Emitter<DocumentState> emit) async {
    try {
      final bool result = await localDocumentApi.deleteOrderDocument(event.value);
      emit(DocumentDeletedState(result: result));
    } catch(e) {
      emit(DocumentErrorState(message: e.toString()));
    }
  }
}
