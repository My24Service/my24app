import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/mobile/blocs/document_states.dart';
import 'package:my24app/mobile/models/document/models.dart';
import '../models/document/api.dart';
import '../models/document/form_data.dart';

enum DocumentEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  NEW,
  DELETE,
  UPDATE,
  INSERT,
  UPDATE_FORM_DATA
}

class DocumentEvent {
  final int pk;
  final int assignedOrderId;
  final dynamic status;
  final AssignedOrderDocument document;
  final AssignedOrderDocumentFormData documentFormData;

  const DocumentEvent({
    this.pk,
    this.assignedOrderId,
    this.status,
    this.document,
    this.documentFormData
  });
}

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  DocumentApi api = DocumentApi();

  DocumentBloc() : super(DocumentInitialState()) {
    on<DocumentEvent>((event, emit) async {
      if (event.status == DocumentEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == DocumentEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == DocumentEventStatus.FETCH_DETAIL) {
        await _handleFetchState(event, emit);
      }
      else if (event.status == DocumentEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == DocumentEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == DocumentEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == DocumentEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == DocumentEventStatus.NEW) {
        _handleNewFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(DocumentEvent event, Emitter<DocumentState> emit) {
    emit(DocumentLoadingState());
  }

  void _handleUpdateFormDataState(DocumentEvent event, Emitter<DocumentState> emit) {
    emit(DocumentLoadedState(documentFormData: event.documentFormData));
  }

  void _handleNewFormDataState(DocumentEvent event, Emitter<DocumentState> emit) {
    emit(DocumentNewState(
        documentFormData: AssignedOrderDocumentFormData.createEmpty(event.assignedOrderId)
    ));
  }

  Future<void> _handleFetchAllState(DocumentEvent event, Emitter<DocumentState> emit) async {
    try {
      final AssignedOrderDocuments documents = await api.list(
          filters: {"assigned_order": event.assignedOrderId});
      emit(DocumentsLoadedState(documents: documents));
    } catch(e) {
      emit(DocumentErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(DocumentEvent event, Emitter<DocumentState> emit) async {
    try {
      final AssignedOrderDocument document = await api.detail(event.pk);
      emit(DocumentLoadedState(
          documentFormData: AssignedOrderDocumentFormData.createFromModel(document)
      ));
    } catch(e) {
      emit(DocumentErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(DocumentEvent event, Emitter<DocumentState> emit) async {
    try {
      final AssignedOrderDocument document = await api.insert(
          event.document);
      emit(DocumentInsertedState(document: document));
    } catch(e) {
      emit(DocumentErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(DocumentEvent event, Emitter<DocumentState> emit) async {
    try {
      final AssignedOrderDocument document = await api.update(event.pk, event.document);
      emit(DocumentUpdatedState(document: document));
    } catch(e) {
      emit(DocumentErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(DocumentEvent event, Emitter<DocumentState> emit) async {
    try {
      final bool result = await api.delete(event.pk);
      emit(DocumentDeletedState(result: result));
    } catch(e) {
      print(e);
      emit(DocumentErrorState(message: e.toString()));
    }
  }
}
