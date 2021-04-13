import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/api/document_api.dart';
import 'package:my24app/order/blocs/document_states.dart';
import 'package:my24app/order/models/models.dart';

enum DocumentEventStatus {
  DO_FETCH,
  FETCH_ALL,
  DELETE,
  INSERT
}

class DocumentEvent {
  final DocumentEventStatus status;
  final int orderPk;
  final dynamic value;

  const DocumentEvent({this.value, this.orderPk, this.status});
}

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  DocumentApi localDocumentApi = documentApi;
  DocumentBloc(DocumentState initialState) : super(initialState);

  @override
  Stream<DocumentState> mapEventToState(event) async* {
    if (event.status == DocumentEventStatus.DO_FETCH) {
      yield DocumentLoadingState();
    }

    if (event.status == DocumentEventStatus.FETCH_ALL) {
      try {
        final OrderDocuments documents = await localDocumentApi.fetchOrderDocuments(event.orderPk);
        yield DocumentsLoadedState(documents: documents);
      } catch(e) {
        yield DocumentErrorState(message: e.toString());
      }
    }

    if (event.status == DocumentEventStatus.DELETE) {
      try {
        final bool result = await localDocumentApi.deleteOrderDocument(event.value);
        yield DocumentDeletedState(result: result);
      } catch(e) {
        yield DocumentErrorState(message: e.toString());
      }
    }

    if (event.status == DocumentEventStatus.INSERT) {
      try {
        final OrderDocument document = await localDocumentApi.insertOrderDocument(event.value, event.orderPk);
        yield DocumentInsertedState(document: document);
      } catch(e) {
        yield DocumentErrorState(message: e.toString());
      }
    }
  }
}
