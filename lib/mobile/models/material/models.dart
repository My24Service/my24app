import 'dart:convert';

import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24app/inventory/models/location/models.dart';

class MaterialPageData {
  final int? preferredLocation;
  final StockLocations? locations;
  final String? memberPicture;

  MaterialPageData({
    this.preferredLocation,
    this.locations,
    this.memberPicture
  });
}

class AssignedOrderMaterial extends BaseModel {
  final int? id;
  final int? assignedOrderId;
  final int? material;
  final int? location;
  final String? locationName;
  final String? materialName;
  final String? materialIdentifier;
  final double? amount;

  AssignedOrderMaterial({
    this.id,
    this.assignedOrderId,
    this.material,
    this.location,
    this.locationName,
    this.materialName,
    this.materialIdentifier,
    this.amount,
  });

  factory AssignedOrderMaterial.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson['amount'] is String) {
      parsedJson['amount'] = double.parse(parsedJson['amount']);
    }

    if (parsedJson['material_identifier'] == null) {
      parsedJson['material_identifier'] = '';
    }

    if (parsedJson['identifier'] == null) {
      parsedJson['identifier'] = '';
    }

    // in case of workorder
    if (parsedJson['material_name'] == null) {
      parsedJson['material_name'] = parsedJson['name'];
    }

    if (parsedJson['material_identifier'] == '' && parsedJson['identifier'] != '') {
      parsedJson['material_identifier'] = parsedJson['identifier'];
    }

    return AssignedOrderMaterial(
      id: parsedJson['id'],
      assignedOrderId: parsedJson['assigned_order'],
      material: parsedJson['material'],
      location: parsedJson['location'],
      materialName: parsedJson['material_name'],
      locationName: parsedJson['location_name'],
      materialIdentifier: parsedJson['material_identifier'],
      amount: parsedJson['amount'],
    );
  }

  @override
  String toJson() {
    final Map body = {
      'assigned_order': this.assignedOrderId,
      'material': this.material,
      'location': this.location,
      'material_name': this.materialName,
      'material_identifier': this.materialIdentifier,
      'amount': this.amount,
    };

    return json.encode(body);
  }
}

class AssignedOrderMaterials extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<AssignedOrderMaterial>? results;

  AssignedOrderMaterials({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory AssignedOrderMaterials.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<AssignedOrderMaterial> results = list.map((i) => AssignedOrderMaterial.fromJson(i)).toList();

    return AssignedOrderMaterials(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}


class AssignedOrderMaterialQuotation extends BaseModel {
  final int? id;
  final int? assignedOrder;
  final int? material;
  final int? amount;
  int? requestedAmount;
  final String? materialName;
  final String? materialIdentifier;
  final String? fullName;

  AssignedOrderMaterialQuotation({
    this.id,
    this.assignedOrder,
    this.material,
    this.amount,
    this.requestedAmount,
    this.materialName,
    this.materialIdentifier,
    this.fullName
  });

  factory AssignedOrderMaterialQuotation.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrderMaterialQuotation(
      id: parsedJson['id'],
      assignedOrder: parsedJson['assigned_order'],
      material: parsedJson['material'],
      amount: double.parse(parsedJson['amount']).round(),
      materialName: parsedJson['material_name'],
      materialIdentifier: parsedJson['material_identifier'],
      fullName: parsedJson['full_name'],
    );
  }

  @override
  String toJson() {
    final Map body = {
    };

    return json.encode(body);
  }
}
