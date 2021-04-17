import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/mobile/api/mobile_api.dart';
import 'package:my24app/mobile/blocs/document_states.dart';
import 'package:my24app/mobile/models/models.dart';

enum DocumentEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  INSERT,
  DELETE
}

class DocumentEvent {
  final dynamic status;
  final AssignedOrderDocument document;
  final dynamic value;

  const DocumentEvent({this.status, this.document, this.value});
}

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  MobileApi localMobileApi = mobileApi;
  DocumentBloc(DocumentState initialState) : super(initialState);

  @override
  Stream<DocumentState> mapEventToState(event) async* {
    if (event.status == DocumentEventStatus.DO_ASYNC) {
      yield DocumentLoadingState();
    }
    if (event.status == DocumentEventStatus.FETCH_ALL) {
      try {
        final AssignedOrderDocuments documents = await localMobileApi.fetchAssignedOrderDocuments(event.value);
        yield DocumentsLoadedState(documents: documents);
      } catch(e) {
        yield DocumentErrorState(message: e.toString());
      }
    }

    if (event.status == DocumentEventStatus.INSERT) {
      try {
        final AssignedOrderDocument document = await localMobileApi.insertAssignedOrderDocument(event.document, event.value);
        yield DocumentInsertedState(document: document);
      } catch(e) {
        yield DocumentErrorState(message: e.toString());
      }
    }

    if (event.status == DocumentEventStatus.DELETE) {
      try {
        final bool result = await localMobileApi.deleteAssignedOrderDocment(event.value);
        yield DocumentDeletedState(result: result);
      } catch(e) {
        yield DocumentErrorState(message: e.toString());
      }
    }
  }
}
