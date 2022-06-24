import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/mobile/api/mobile_api.dart';
import 'package:my24app/mobile/blocs/document_states.dart';
import 'package:my24app/mobile/models/models.dart';

enum DocumentEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  INSERTED,
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

  DocumentBloc() : super(DocumentInitialState()) {
    on<DocumentEvent>((event, emit) async {
      if (event.status == DocumentEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      if (event.status == DocumentEventStatus.INSERTED) {
        _handleInsertedState(event, emit);
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

  void _handleInsertedState(DocumentEvent event, Emitter<DocumentState> emit) {
    emit(DocumentInsertedState());
  }

  Future<void> _handleFetchAllState(DocumentEvent event, Emitter<DocumentState> emit) async {
    try {
      final AssignedOrderDocuments documents = await localMobileApi.fetchAssignedOrderDocuments(event.value);
      emit(DocumentsLoadedState(documents: documents));
    } catch(e) {
      emit(DocumentErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(DocumentEvent event, Emitter<DocumentState> emit) async {
    try {
      final bool result = await localMobileApi.deleteAssignedOrderDocment(event.value);
      emit(DocumentDeletedState(result: result));
    } catch(e) {
      emit(DocumentErrorState(message: e.toString()));
    }
  }
}
