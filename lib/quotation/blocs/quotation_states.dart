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

class QuotationSearchState extends QuotationState {
  @override
  List<Object> get props => [];
}

class QuotationRefreshState extends QuotationState {
  @override
  List<Object> get props => [];
}

class QuotationsLoadedState extends QuotationState {
  final Quotations quotations;
  final String query;

  QuotationsLoadedState({this.quotations, this.query});

  @override
  List<Object> get props => [quotations, query];
}

class QuotationsUnacceptedLoadedState extends QuotationState {
  final Quotations quotations;
  final String query;

  QuotationsUnacceptedLoadedState({this.quotations, this.query});

  @override
  List<Object> get props => [quotations, query];
}

class QuotationDeletedState extends QuotationState {
  final bool result;

  QuotationDeletedState({this.result});

  @override
  List<Object> get props => [result];
}

class QuotationAcceptedState extends QuotationState {
  final bool result;

  QuotationAcceptedState({this.result});

  @override
  List<Object> get props => [result];
}
