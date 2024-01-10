import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'models.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class QuotationLineFormData extends BaseFormData<QuotationLine> {
  int? id;
  int? quotation;
  int? chapter;
  double? vatType = 0;

  TextEditingController? infoController = TextEditingController();
  TextEditingController? amountController = TextEditingController(text: '0');
  TextEditingController? priceController = TextEditingController(text: '0.0');
  TextEditingController? totalController = TextEditingController(text: '0.0');
  TextEditingController? vatController = TextEditingController(text: '0.0');

  QuotationLineFormData(
      {this.id,
      this.quotation,
      this.chapter,
      this.infoController,
      this.amountController,
      this.priceController,
      this.totalController,
      this.vatController,
      this.vatType});

  @override
  QuotationLine toModel() {
    return QuotationLine(
        id: id,
        quotation: quotation,
        chapter: chapter,
        info: infoController!.text,
        amount: int.parse(amountController!.text),
        price: _convertCurrencyToDouble(priceController!.text),
        total: _convertCurrencyToDouble(totalController!.text),
        vat: _convertCurrencyToDouble(vatController!.text),
        vat_type: vatType);
  }

  _convertCurrencyToDouble(String text) {
    String value = toNumericString(text);
    return double.parse(value) / 100;
  }

  factory QuotationLineFormData.createEmpty() {
    TextEditingController infoController = TextEditingController();
    TextEditingController amountController = TextEditingController(text: '0');
    TextEditingController priceController = TextEditingController(text: '0.00');
    TextEditingController totalController = TextEditingController(text: '0.00');
    TextEditingController vatController = TextEditingController(text: '0.00');

    return QuotationLineFormData(
        id: null,
        quotation: null,
        chapter: null,
        infoController: infoController,
        amountController: amountController,
        priceController: priceController,
        totalController: totalController,
        vatController: vatController,
        vatType: 0);
  }

  factory QuotationLineFormData.createFromModel(QuotationLine quotationLine) {
    TextEditingController infoController = TextEditingController();
    infoController.text = checkNull(quotationLine.info);
    TextEditingController amountController = TextEditingController();
    amountController.text = checkNumberNull(quotationLine.amount).toString();
    TextEditingController priceController = TextEditingController();
    priceController.text = toCurrencyString(quotationLine.price.toString(),
        leadingSymbol: CurrencySymbols.EURO_SIGN);
    TextEditingController totalController = TextEditingController();
    totalController.text = toCurrencyString(quotationLine.total.toString(),
        leadingSymbol: CurrencySymbols.EURO_SIGN);
    TextEditingController vatController = TextEditingController();
    vatController.text = toCurrencyString(quotationLine.vat.toString(),
        leadingSymbol: CurrencySymbols.EURO_SIGN);

    return QuotationLineFormData(
        id: quotationLine.id,
        quotation: quotationLine.quotation,
        chapter: quotationLine.chapter,
        infoController: infoController,
        amountController: amountController,
        priceController: priceController,
        totalController: totalController,
        vatController: vatController,
        vatType: quotationLine.vat_type);
  }
}
