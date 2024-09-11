import 'dart:convert';

import 'package:my24_flutter_core/models/base_models.dart';

class MaterialModel extends BaseModel {
  final int? id;
  final String? identifier;
  final String? showName;
  final String? name;
  final String? nameShort;
  final String? unit;
  final String? supplier;
  final int? supplierRelation;
  final String? productType;
  final String? pricePurchase;
  final String? priceSelling;
  final String? priceSellingAlt;
  final String? pricePurchaseEx;
  final String? priceSellingEx;
  final String? priceSellingAltEx;
  final String? image;

  MaterialModel({
    this.id,
    this.identifier,
    this.showName,
    this.name,
    this.nameShort,
    this.unit,
    this.supplier,
    this.supplierRelation,
    this.productType,
    this.pricePurchase,
    this.priceSelling,
    this.priceSellingAlt,
    this.pricePurchaseEx,
    this.priceSellingEx,
    this.priceSellingAltEx,
    this.image
  });

  factory MaterialModel.fromJson(Map<String, dynamic> parsedJson) {
    return MaterialModel(
      id: parsedJson['id'],
      identifier: parsedJson['identifier'],
      showName: parsedJson['show_name'],
      name: parsedJson['name'],
      nameShort: parsedJson['name_short'],
      unit: parsedJson['unit'],
      supplier: parsedJson['supplier'],
      supplierRelation: parsedJson['supplier_relation'],
      productType: parsedJson['product_type'],
      pricePurchase: parsedJson['price_purchase'],
      priceSelling: parsedJson['price_selling'],
      priceSellingAlt: parsedJson['price_selling_alt'],
      pricePurchaseEx: parsedJson['price_purchase_ex'],
      priceSellingEx: parsedJson['price_selling_ex'],
      priceSellingAltEx: parsedJson['priceSelling_alt_ex'],
      image: parsedJson['image'],
    );
  }

  @override
  String toJson() {
    Map body = {
      'id': this.id,
      'identifier': this.identifier,
      'name': this.name,
      'name_short': this.nameShort,
      'unit': this.unit,
      'supplier': this.supplier,
      'supplier_relation': this.supplierRelation,
      'product_type': this.productType,
      'price_purchase': this.pricePurchase ?? '0.00',
      'price_selling': this.priceSelling ?? '0.00',
      'price_selling_alt': this.priceSellingAlt ?? '0.00',
      'price_purchase_ex': this.pricePurchaseEx ?? '0.00',
      'price_selling_ex': this.priceSellingEx ?? '0.00',
      'price_selling_alt_ex': this.priceSellingAltEx ?? '0.00',
    };

    if (this.image != null) {
      body['image'] = this.image;
    }

    return json.encode(body);
  }
}

class Materials extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<MaterialModel>? results;

  Materials({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Materials.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<MaterialModel> results = list.map((i) => MaterialModel.fromJson(i)).toList();

    return Materials(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

// used in mobile assigned order materials search
class MaterialTypeAheadModel {
  final int? id;
  final String? materialName;
  final String? materialIdentifier;
  final String? value;

  MaterialTypeAheadModel({
    this.id,
    this.materialName,
    this.materialIdentifier,
    this.value,
  });

  factory MaterialTypeAheadModel.fromJson(Map<String, dynamic> parsedJson) {
    return MaterialTypeAheadModel(
      id: parsedJson['id'],
      materialName: parsedJson['name'],
      materialIdentifier: parsedJson['identifier'],
      value: parsedJson['value'],
    );
  }
}

class MaterialMinimalModel extends BaseModel {
  final int? id;
  final String? identifier;
  final String? showName;
  final String? name;
  final String? nameShort;

  MaterialMinimalModel({
    this.id,
    this.identifier,
    this.showName,
    this.name,
    this.nameShort,
  });

  factory MaterialMinimalModel.fromJson(Map<String, dynamic> parsedJson) {
    return MaterialMinimalModel(
      id: parsedJson['id'],
      identifier: parsedJson['identifier'],
      showName: parsedJson['show_name'],
      name: parsedJson['name'],
      nameShort: parsedJson['name_short'],
    );
  }

  @override
  String toJson() {
    Map body = {
      'id': this.id,
      'identifier': this.identifier,
      'name': this.name,
      'name_short': this.nameShort,
    };

    return json.encode(body);
  }
}
