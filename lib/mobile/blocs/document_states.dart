import 'package:equatable/equatable.dart';
import 'package:my24app/mobile/models/models.dart';

abstract class DocumentState extends Equatable {}

class DocumentInitialState extends DocumentState {
  @override
  List<Object> get props => [];
}

class DocumentLoadingState extends DocumentState {
  @override
  List<Object> get props => [];
}

class DocumentInsertedState extends DocumentState {
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
  final AssignedOrderDocuments documents;

  DocumentsLoadedState({this.documents});

  @override
  List<Object> get props => [documents];
}

class DocumentLoadedState extends DocumentState {
  final AssignedOrderDocument document;

  DocumentLoadedState({this.document});

  @override
  List<Object> get props => [document];
}

class DocumentDeletedState extends DocumentState {
  final bool result;

  DocumentDeletedState({this.result});

  @override
  List<Object> get props => [result];
}
