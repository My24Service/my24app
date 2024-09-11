// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:my24_flutter_core/models/base_models.dart';

class QuotationLine extends BaseModel {
  final int? id;
  final int? quotation;
  final int? chapter;
  final String? info;
  final String? extra_description;
  final int? amount;
  final double? price;
  final double? total;
  final double? vat;
  final double? vat_type;

  QuotationLine(
      {this.id,
      this.quotation,
      this.chapter,
      this.info,
      this.amount,
      this.price,
      this.total,
      this.vat,
      this.vat_type,
      this.extra_description});

  factory QuotationLine.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationLine(
        id: parsedJson['id'],
        quotation: parsedJson['quotation'],
        chapter: parsedJson['chapter'],
        info: parsedJson['info'],
        extra_description: parsedJson['extra_description'],
        amount: int.parse(parsedJson['amount']),
        price: double.parse(parsedJson['price']),
        total: double.parse(parsedJson['total']),
        vat: double.parse(parsedJson['vat']),
        vat_type: double.parse(parsedJson['vat_type']));
  }

  @override
  String toJson() {
    final Map<String, dynamic> body = {
      'quotation': quotation,
      'chapter': chapter,
      'info': info,
      'amount': amount,
      'price': price,
      'total': total,
      'vat': vat,
      'vat_type': vat_type,
      'extra_description': extra_description
    };

    return json.encode(body);
  }
}

class QuotationLines extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<QuotationLine>? results;

  QuotationLines({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory QuotationLines.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<QuotationLine> results =
        list.map((i) => QuotationLine.fromJson(i)).toList();

    return QuotationLines(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class QuotationLineMaterial extends BaseModel {
  final String? material_name;
  final String? material_identifier;
  final int? material;
  int? amount;

  QuotationLineMaterial({this.material_name,
    this.material_identifier,
    this.material,
    this.amount,
  });

  factory QuotationLineMaterial.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationLineMaterial(
      material_name: parsedJson['material_name'],
      material_identifier: parsedJson['material_identifier'],
      material: parsedJson['material'],
      amount: double.parse(parsedJson['amount']).round(),
    );
  }

  @override
  String toJson() {
    final Map<String, dynamic> body = {
      'material_name': material_name,
      'material_identifier': material_identifier,
      'material': material,
      'amount': amount,
    };

    return json.encode(body);
  }
}
