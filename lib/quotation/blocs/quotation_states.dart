import 'package:equatable/equatable.dart';

import 'package:my24app/quotation/models/quotation/models.dart';
import 'package:my24app/quotation/models/quotation/form_data.dart';

abstract class QuotationState extends Equatable {}

// quotations
class QuotationInitialState extends QuotationState {
  @override
  List<Object> get props => [];
}

class QuotationLoadingState extends QuotationState {
  @override
  List<Object> get props => [];
}

class QuotationLoadedState extends QuotationState {
  final Quotation? quotation;
  final QuotationFormData? formData;

  QuotationLoadedState({this.quotation, this.formData});

  @override
  List<Object?> get props => [quotation, formData];
}

class QuotationErrorState extends QuotationState {
  final String? message;

  QuotationErrorState({this.message});

  @override
  List<Object?> get props => [message];
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
  final Quotations? quotations;
  final String? query;
  final int? page;

  QuotationsLoadedState({this.quotations, this.query, this.page});

  @override
  List<Object?> get props => [quotations, query];
}

class QuotationsUnacceptedLoadedState extends QuotationState {
  final Quotations? quotations;
  final String? query;

  QuotationsUnacceptedLoadedState({this.quotations, this.query});

  @override
  List<Object?> get props => [quotations, query];
}

class QuotationsPreliminaryLoadedState extends QuotationState {
  final Quotations? quotations;
  final String? query;
  final int? page;

  QuotationsPreliminaryLoadedState({this.quotations, this.query, this.page});

  @override
  List<Object?> get props => [quotations, query];
}

class QuotationDeletedState extends QuotationState {
  final bool? result;

  QuotationDeletedState({this.result});

  @override
  List<Object?> get props => [result];
}

class QuotationAcceptedState extends QuotationState {
  final bool? result;

  QuotationAcceptedState({this.result});

  @override
  List<Object?> get props => [result];
}

class QuotationDefinitiveState extends QuotationState {
  final bool? result;

  QuotationDefinitiveState({this.result});

  @override
  List<Object?> get props => [result];
}

class QuotationInsertedState extends QuotationState {
  final Quotation? quotation;
  final QuotationFormData? formData;

  QuotationInsertedState({this.quotation, this.formData});

  @override
  List<Object?> get props => [quotation, formData];
}

class QuotationEditedState extends QuotationState {
  final Quotation? result;

  QuotationEditedState({this.result});

  @override
  List<Object?> get props => [result];
}

class QuotationNewState extends QuotationState {
  final QuotationFormData? formData;

  QuotationNewState({this.formData});

  @override
  List<Object?> get props => [formData];
}

enum QuotationSaveStatus {
  IS_CREATED,
  IS_UPDATED,
}

class QuotationUpdateState extends QuotationNewState {
  final QuotationSaveStatus? status;
  final QuotationFormData? formData;

  QuotationUpdateState({this.formData, this.status})
      : super(formData: formData);
}
