import 'package:equatable/equatable.dart';

import 'package:my24app/quotation/models/models.dart';

abstract class QuotationPartState extends Equatable {}

// quotation parts
class QuotationPartInitialState extends QuotationPartState {
  @override
  List<Object> get props => [];
}

class QuotationPartNewState extends QuotationPartState {
  @override
  List<Object> get props => [];
}

class QuotationPartLoadingState extends QuotationPartState {
  @override
  List<Object> get props => [];
}

class QuotationPartLoadedState extends QuotationPartState {
  final QuotationPart? part;

  QuotationPartLoadedState({this.part});

  @override
  List<Object?> get props => [part];
}

class QuotationPartErrorState extends QuotationPartState {
  final String? message;

  QuotationPartErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class QuotationPartsLoadedState extends QuotationPartState {
  final List<QuotationPart>? result;

  QuotationPartsLoadedState({this.result});

  @override
  List<Object?> get props => [result];
}

class QuotationPartDeletedState extends QuotationPartState {
  final bool? result;

  QuotationPartDeletedState({this.result});

  @override
  List<Object?> get props => [result];
}

class QuotationPartEditedState extends QuotationPartState {
  final bool? result;
  final int? quotationPartPk;

  QuotationPartEditedState({this.result, this.quotationPartPk});

  @override
  List<Object?> get props => [result];
}

class QuotationPartInsertedState extends QuotationPartState {
  final QuotationPart? part;

  QuotationPartInsertedState({this.part});

  @override
  List<Object?> get props => [part];
}
