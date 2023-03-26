import 'package:equatable/equatable.dart';
import 'package:my24app/mobile/models/document/models.dart';

import '../models/document/form_data.dart';

abstract class DocumentState extends Equatable {}

class DocumentInitialState extends DocumentState {
  @override
  List<Object> get props => [];
}

class DocumentLoadingState extends DocumentState {
  @override
  List<Object> get props => [];
}

class DocumentErrorState extends DocumentState {
  final String message;

  DocumentErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class DocumentInsertedState extends DocumentState {
  final AssignedOrderDocument document;

  DocumentInsertedState({this.document});

  @override
  List<Object> get props => [document];
}

class DocumentUpdatedState extends DocumentState {
  final AssignedOrderDocument document;

  DocumentUpdatedState({this.document});

  @override
  List<Object> get props => [document];
}

class DocumentsLoadedState extends DocumentState {
  final AssignedOrderDocuments documents;
  final int page;

  DocumentsLoadedState({this.documents, this.page});

  @override
  List<Object> get props => [documents, page];
}

class DocumentLoadedState extends DocumentState {
  final AssignedOrderDocumentFormData documentFormData;

  DocumentLoadedState({this.documentFormData});

  @override
  List<Object> get props => [documentFormData];
}

class DocumentNewState extends DocumentState {
  final AssignedOrderDocumentFormData documentFormData;

  DocumentNewState({this.documentFormData});

  @override
  List<Object> get props => [documentFormData];
}

class DocumentDeletedState extends DocumentState {
  final bool result;

  DocumentDeletedState({this.result});

  @override
  List<Object> get props => [result];
}
