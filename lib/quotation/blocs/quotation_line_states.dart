import 'package:equatable/equatable.dart';

import 'package:my24app/quotation/models/quotation_line/models.dart';
import 'package:my24app/quotation/models/quotation_line/form_data.dart';

enum QuotationLineStatus { loading, success, error }

class QuotationLineState extends Equatable {
  final QuotationLineStatus? status;
  final QuotationLineForms? quotationLineForms;
  final String? message;

  QuotationLineState(
      {this.quotationLineForms,
      this.status = QuotationLineStatus.loading,
      this.message});

  factory QuotationLineState.init() {
    return QuotationLineState(quotationLineForms: QuotationLineForms());
  }

  factory QuotationLineState.loading() {
    return QuotationLineState();
  }

  factory QuotationLineState.success(QuotationLineForms quotationLineForms) {
    return QuotationLineState(
        quotationLineForms: quotationLineForms,
        status: QuotationLineStatus.success);
  }

  factory QuotationLineState.error(message) {
    return QuotationLineState(
        status: QuotationLineStatus.error, message: message);
  }

  @override
  List<Object?> get props => [quotationLineForms, status, message];
}

class QuotationLineDeletedState extends QuotationLineState {
  @override
  List<Object?> get props => [];
}
