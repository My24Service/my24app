import 'package:equatable/equatable.dart';

import 'package:my24app/quotation/models/models.dart';

abstract class QuotationState extends Equatable {}

class QuotationInitialState extends QuotationState {
  @override
  List<Object> get props => [];
}

class QuotationLoadingState extends QuotationState {
  @override
  List<Object> get props => [];
}

class QuotationErrorState extends QuotationState {
  final String message;

  QuotationErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class QuotationsLoadedState extends QuotationState {
  final Quotations quotations;

  QuotationsLoadedState({this.quotations});

  @override
  List<Object> get props => [quotations];
}

class QuotationsUnacceptedLoadedState extends QuotationState {
  final Quotations quotations;

  QuotationsUnacceptedLoadedState({this.quotations});

  @override
  List<Object> get props => [quotations];
}

class QuotationDeletedState extends QuotationState {
  final bool result;

  QuotationDeletedState({this.result});

  @override
  List<Object> get props => [result];
}

class QuotationInsertedState extends QuotationState {
  final Quotation quotation;

  QuotationInsertedState({this.quotation});

  @override
  List<Object> get props => [quotation];
}

class QuotationAcceptedState extends QuotationState {
  final bool result;

  QuotationAcceptedState({this.result});

  @override
  List<Object> get props => [result];
}
