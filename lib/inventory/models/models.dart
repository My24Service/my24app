import 'dart:convert';

class StockLocation {
  final int id;
  final String identifier;
  final String name;

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
}

class StockLocations {
  final int count;
  final String next;
  final String previous;
  final List<StockLocation> results;

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
  final int id;
  final String identifier;
  final String showName;
  final String name;
  final String nameShort;
  final String unit;
  final String supplier;
  final int supplierRelation;
  final String productType;
  final String pricePurchase;
  final String priceSelling;
  final String priceSellingAlt;
  final String pricePurchaseEx;
  final String priceSellingEx;
  final String priceSellingAltEx;

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

class LocationInventory {
  final int id;
  final int amount;
  final int salesAmountToday;
  final InventoryMaterial material;
  final StockLocation location;

  LocationInventory({
    this.id,
    this.amount,
    this.salesAmountToday,
    this.material,
    this.location,
  });

  factory LocationInventory.fromJson(Map<String, dynamic> parsedJson) {
    InventoryMaterial material = InventoryMaterial.fromJson(parsedJson['material']);
    StockLocation location = StockLocation.fromJson(parsedJson['location']);

    return LocationInventory(
      id: parsedJson['id'],
      amount: parsedJson['amount'],
      salesAmountToday: parsedJson['sales_amount_today'],
      material: material,
      location: location,
    );
  }
}

class LocationInventoryResults {
  final int count;
  final String next;
  final String previous;
  final List<LocationInventory> results;

  LocationInventoryResults({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory LocationInventoryResults.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<LocationInventory> results = list.map((i) => LocationInventory.fromJson(i)).toList();

    return LocationInventoryResults(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class InventoryMaterialTypeAheadModel {
  final int id;
  final String materialName;
  final String materialIdentifier;
  final String value;

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
