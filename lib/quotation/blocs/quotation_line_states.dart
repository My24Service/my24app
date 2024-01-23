import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:my24app/quotation/models/quotation_line/models.dart';
import 'package:my24app/quotation/models/quotation_line/form_data.dart';

abstract class QuotationLineState extends Equatable {}

class QuotationLineInitialState extends QuotationLineState {
  @override
  List<Object> get props => [];
}

class QuotationLineLoadingState extends QuotationLineState {
  @override
  List<Object> get props => [];
}

class QuotationLinesLoadedState extends QuotationLineState {
  final QuotationLines? quotationLines;
  final String? query;
  final int? page;

  QuotationLinesLoadedState({this.quotationLines, this.query, this.page});

  @override
  List<Object?> get props => [quotationLines, query, page];
}

class QuotationLineErrorState extends QuotationLineState {
  final String? message;

  QuotationLineErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class QuotationLineInsertedState extends QuotationLineState {
  final QuotationLine? quotationLine;

  QuotationLineInsertedState({
    this.quotationLine,
  });

  @override
  List<Object?> get props => [
        quotationLine,
      ];
}

class NewQuotationLinesFormState extends QuotationLineState {
  final Map<GlobalKey<FormState>, QuotationLineFormData>?
      quotationLinesFormsMap;

  NewQuotationLinesFormState({this.quotationLinesFormsMap});

  @override
  List<Object?> get props => [quotationLinesFormsMap];
}
