import 'dart:convert';

import 'package:my24_flutter_core/models/base_models.dart';

class Orderline extends BaseModel {
  final int? id;
  int? order;
  final String? product;
  final String? location;
  final String? remarks;
  final double? pricePurchase;
  final double? priceSelling;
  final int? materialRelation;
  final int? amount;
  final int? locationRelationInventory;
  final int? equipment;
  final int? equipmentLocation;

  Orderline({
    this.id,
    this.order,
    this.product,
    this.location,
    this.remarks,
    this.pricePurchase,
    this.priceSelling,
    this.materialRelation,
    this.amount,
    this.locationRelationInventory,
    this.equipment,
    this.equipmentLocation
  });

  factory Orderline.fromJson(Map<String, dynamic> parsedJson) {
    double pricePurchase = parsedJson['price_purchase'] != null ? double.parse(parsedJson['price_purchase']) : 0;
    double priceSelling = parsedJson['price_selling'] != null ? double.parse(parsedJson['price_selling']) : 0;

    return Orderline(
      id: parsedJson['id'],
      order: parsedJson['order'],
      product: parsedJson['product'],
      location: parsedJson['location'],
      remarks: parsedJson['remarks'],
      pricePurchase: pricePurchase,
      priceSelling: priceSelling,
      materialRelation: parsedJson['material_relation'],
      locationRelationInventory: parsedJson['location_relation_inventory'],
      amount: parsedJson['amount'],
      equipment: parsedJson['equipment'],
      equipmentLocation: parsedJson['equipment_location'],
    );
  }

  @override
  String toJson() {
    Map body = {
      'id': this.id,
      'order': this.order,
      'product': this.product,
      'location': this.location,
      'remarks': this.remarks,
      'material_relation': this.materialRelation,
      'location_relation_inventory': this.locationRelationInventory,
      'amount': this.amount == null ? 0 : this.amount,
      'equipment': this.equipment,
      'equipment_location': this.equipmentLocation
    };

    return json.encode(body);
  }
}

class Orderlines extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<Orderline>? results;

  Orderlines({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Orderlines.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Orderline> results = list.map((i) => Orderline.fromJson(i)).toList();

    return Orderlines(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}
