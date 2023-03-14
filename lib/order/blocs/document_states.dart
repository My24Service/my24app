import 'package:equatable/equatable.dart';

import 'package:my24app/order/models/document/models.dart';

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

class DocumentsLoadedState extends DocumentState {
  final OrderDocuments documents;

  DocumentsLoadedState({this.documents});

  @override
  List<Object> get props => [documents];
}

class DocumentDeletedState extends DocumentState {
  final bool result;

  DocumentDeletedState({this.result});

  @override
  List<Object> get props => [result];
}
