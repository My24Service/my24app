import 'package:equatable/equatable.dart';

import 'package:my24app/order/models/document/models.dart';

import '../models/document/form_data.dart';

abstract class OrderDocumentState extends Equatable {}

class OrderDocumentInitialState extends OrderDocumentState {
  @override
  List<Object> get props => [];
}

class OrderDocumentLoadingState extends OrderDocumentState {
  @override
  List<Object> get props => [];
}

class OrderDocumentErrorState extends OrderDocumentState {
  final String message;

  OrderDocumentErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class OrderDocumentInsertedState extends OrderDocumentState {
  final OrderDocument document;

  OrderDocumentInsertedState({this.document});

  @override
  List<Object> get props => [document];
}


class OrderDocumentUpdatedState extends OrderDocumentState {
  final OrderDocument document;

  OrderDocumentUpdatedState({this.document});

  @override
  List<Object> get props => [document];
}

class OrderDocumentsLoadedState extends OrderDocumentState {
  final OrderDocuments documents;
  final int page;

  OrderDocumentsLoadedState({this.documents, this.page});

  @override
  List<Object> get props => [documents, page];
}

class OrderDocumentLoadedState extends OrderDocumentState {
  final OrderDocumentFormData documentFormData;

  OrderDocumentLoadedState({this.documentFormData});

  @override
  List<Object> get props => [documentFormData];
}

class OrderDocumentNewState extends OrderDocumentState {
  final OrderDocumentFormData documentFormData;
  final bool fromEmpty;

  OrderDocumentNewState({
    this.documentFormData,
    this.fromEmpty
  });

  @override
  List<Object> get props => [documentFormData, fromEmpty];
}

class OrderDocumentDeletedState extends OrderDocumentState {
  final bool result;

  OrderDocumentDeletedState({this.result});

  @override
  List<Object> get props => [result];
}
