import 'package:my24_flutter_core/models/base_models.dart';
import 'models.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class QuotationLineFormData extends BaseFormData<QuotationLine> {
  int? id;
  int? quotation;
  int? chapter;
  double? vatType = 0;
  String? info;
  String? amount;
  String? price;
  String? total;
  String? vat;
  String? extraDescription;

  QuotationLineFormData(
      {this.id,
      this.quotation,
      this.chapter,
      this.info,
      this.amount,
      this.price,
      this.total,
      this.vat,
      this.vatType,
      this.extraDescription});

  dynamic getProp(String key) => <String, dynamic>{
        'info': info,
        'amount': amount,
        'price': price,
        'total': total,
        'vat': vat,
        'extraDescription': extraDescription
      }[key];

  dynamic setProp(String key, String value) {
    switch (key) {
      case 'info':
        this.info = value;
        break;
      case 'extraDescription':
        this.extraDescription = value;
        break;
      case 'amount':
        this.amount = value;
        break;
      case 'price':
        this.price = value;
        break;
      case 'total':
        this.total = value;
        break;
      case 'vat':
        this.vat = value;
        break;
      default:
        throw Exception("unknown field: $key");
    }
  }

  @override
  QuotationLine toModel() {
    return QuotationLine(
        id: id,
        quotation: quotation,
        chapter: chapter,
        info: info,
        extra_description: extraDescription,
        amount: int.parse(amount ?? '0'),
        price: _convertCurrencyToDouble(price!),
        total: _convertCurrencyToDouble(total!),
        vat: _convertCurrencyToDouble(vat!),
        vat_type: vatType);
  }

  _convertCurrencyToDouble(String text) {
    String value = toNumericString(text);
    return double.parse(value) / 100;
  }

  factory QuotationLineFormData.createEmpty() {
    return QuotationLineFormData(
        id: null,
        quotation: null,
        chapter: null,
        info: null,
        extraDescription: null,
        amount: null,
        price: null,
        total: null,
        vat: null,
        vatType: 0);
  }

  factory QuotationLineFormData.createFromModel(
      QuotationLine quotationLine, String currencySymbol) {
    return QuotationLineFormData(
        id: quotationLine.id,
        quotation: quotationLine.quotation,
        chapter: quotationLine.chapter,
        info: quotationLine.info,
        extraDescription: quotationLine.extra_description,
        amount: checkNumberNull(quotationLine.amount).toString(),
        price: toCurrencyString(quotationLine.price.toString(),
            leadingSymbol: currencySymbol),
        total: toCurrencyString(quotationLine.total.toString(),
            leadingSymbol: currencySymbol),
        vat: toCurrencyString(quotationLine.vat.toString(),
            leadingSymbol: currencySymbol),
        vatType: quotationLine.vat_type);
  }
}

class QuotationLineForms {
  List<QuotationLine>? quotationLines;
  QuotationLineFormData? quotationLineFormData;
  String? currency;

  QuotationLineForms(
      {this.quotationLines = const <QuotationLine>[],
      quotationLineFormData,
      this.currency})
      : quotationLineFormData =
            quotationLineFormData ?? QuotationLineFormData.createEmpty();

  void newQuotationLineForm() {
    this.quotationLineFormData = QuotationLineFormData.createEmpty();
  }
}
