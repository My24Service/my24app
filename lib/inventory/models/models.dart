import 'package:flutter/material.dart';

import 'package:my24_flutter_core/models/base_models.dart';

class LocationInventoryPageData {
  final StockLocations locations;
  final String? memberPicture;
  final Widget? drawer;

  LocationInventoryPageData({
    required this.locations,
    required this.memberPicture,
    required this.drawer,
  });
}

class LocationsData {
  StockLocations? locations;
  List<LocationMaterialInventory>? locationProducts;
  String? location;
  int? locationId;
}

class StockLocation extends BaseModel {
  final int? id;
  final String? identifier;
  final String? name;

  StockLocation({
    this.id,
    this.identifier,
    this.name,
  });

  factory StockLocation.fromJson(Map<String, dynamic> parsedJson) {
    return StockLocation(
      id: parsedJson['id'],
      identifier: parsedJson['identifier'],
      name: parsedJson['name'],
    );
  }

  @override
  String toJson() {
    return '';
  }
}

class StockLocations extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<StockLocation>? results;

  StockLocations({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory StockLocations.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<StockLocation> results = list.map((i) => StockLocation.fromJson(i)).toList();

    return StockLocations(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class InventoryMaterial {
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

  InventoryMaterial({
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
  });

  factory InventoryMaterial.fromJson(Map<String, dynamic> parsedJson) {
    return InventoryMaterial(
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
    );
  }
}

class LocationMaterialInventory {
  final int? totalAmount;
  final int? numSoldToday;
  final int? materialId;
  final String? materialName;
  final String? materialIdentifier;
  final double? pricePurchase;
  final double? priceSelling;
  final double? priceSellingAlt;
  final String? supplierName;

  LocationMaterialInventory({
    this.totalAmount,
    this.numSoldToday,
    this.materialId,
    this.materialName,
    this.materialIdentifier,
    this.pricePurchase,
    this.priceSelling,
    this.priceSellingAlt,
    this.supplierName,
  });

  factory LocationMaterialInventory.fromJson(Map<String, dynamic> parsedJson) {
    return LocationMaterialInventory(
      totalAmount: parsedJson['total_amount'],
      numSoldToday: parsedJson['num_sold_today'],
      materialId: parsedJson['material_id'],
      materialName: parsedJson['material_name'],
      materialIdentifier: parsedJson['material_identifier'],
      supplierName: parsedJson['supplier_name'],
      pricePurchase: double.parse(parsedJson['price_purchase']),
      priceSelling: double.parse(parsedJson['price_selling']),
      priceSellingAlt: double.parse(parsedJson['price_selling_alt']),
    );
  }
}

class LocationMaterialMutation {
  final int? amount;
  final int? numSoldToday;
  final int? materialId;
  final String? materialName;
  final String? materialIdentifier;
  final String? locationName;
  final int? locationId;
  final double? pricePurchase;
  final double? priceSelling;
  final double? priceSellingAlt;
  final String? customerName;

  LocationMaterialMutation({
    this.amount,
    this.numSoldToday,
    this.materialId,
    this.materialName,
    this.materialIdentifier,
    this.locationName,
    this.locationId,
    this.pricePurchase,
    this.priceSelling,
    this.priceSellingAlt,
    this.customerName,
  });
}

// used in mobile assigned order materials search
class InventoryMaterialTypeAheadModel {
  final int? id;
  final String? materialName;
  final String? materialIdentifier;
  final String? value;

  InventoryMaterialTypeAheadModel({
    this.id,
    this.materialName,
    this.materialIdentifier,
    this.value,
  });

  factory InventoryMaterialTypeAheadModel.fromJson(Map<String, dynamic> parsedJson) {
    return InventoryMaterialTypeAheadModel(
      id: parsedJson['id'],
      materialName: parsedJson['name'],
      materialIdentifier: parsedJson['identifier'],
      value: parsedJson['value'],
    );
  }
}
