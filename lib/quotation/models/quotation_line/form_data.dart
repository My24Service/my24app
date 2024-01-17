import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
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

  QuotationLineFormData(
      {this.id,
      this.quotation,
      this.chapter,
      this.info,
      this.amount,
      this.price,
      this.total,
      this.vat,
      this.vatType});

  dynamic getProp(String key) => <String, dynamic>{
        'info': info,
        'amount': amount,
        'price': price,
        'total': total,
        'vat': vat,
      }[key];

  dynamic setProp(String key, String value) {
    switch (key) {
      case 'info':
        this.info = value;
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
        amount: int.parse(amount!),
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
        amount: null,
        price: null,
        total: null,
        vat: null,
        vatType: 0);
  }

  factory QuotationLineFormData.createFromModel(QuotationLine quotationLine) {
    return QuotationLineFormData(
        id: quotationLine.id,
        quotation: quotationLine.quotation,
        chapter: quotationLine.chapter,
        info: quotationLine.info,
        amount: checkNumberNull(quotationLine.amount).toString(),
        price: toCurrencyString(quotationLine.price.toString(),
            leadingSymbol: CurrencySymbols.EURO_SIGN),
        total: toCurrencyString(quotationLine.total.toString(),
            leadingSymbol: CurrencySymbols.EURO_SIGN),
        vat: toCurrencyString(quotationLine.vat.toString(),
            leadingSymbol: CurrencySymbols.EURO_SIGN),
        vatType: quotationLine.vat_type);
  }
}
