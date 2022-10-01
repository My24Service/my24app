import 'package:equatable/equatable.dart';

import 'package:my24app/quotation/models/models.dart';

abstract class PartLineState extends Equatable {}

class PartLineInitialState extends PartLineState {
  @override
  List<Object> get props => [];
}

class PartLineLoadingState extends PartLineState {
  @override
  List<Object> get props => [];
}

class PartLineErrorState extends PartLineState {
  final String message;

  PartLineErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class PartLinesLoadedState extends PartLineState {
  final QuotationPartLines result;

  PartLinesLoadedState({this.result});

  @override
  List<Object> get props => [result];
}

class PartLineInsertedState extends PartLineState {
  final QuotationPartLine line;

  PartLineInsertedState({this.line});

  @override
  List<Object> get props => [line];
}

class PartLineEditedState extends PartLineState {
  final bool result;

  PartLineEditedState({this.result});

  @override
  List<Object> get props => [result];
}

class PartLineDeletedState extends PartLineState {
  final bool result;

  PartLineDeletedState({this.result});

  @override
  List<Object> get props => [result];
}

class PartLineLoadedState extends PartLineState {
  final QuotationPartLine line;

  PartLineLoadedState({this.line});

  @override
  List<Object> get props => [line];
}
