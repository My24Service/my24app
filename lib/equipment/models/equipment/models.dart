import 'dart:convert';

import 'package:my24_flutter_core/models/base_models.dart';

class Equipment extends BaseModel {
  final int? id;
  final String? identifier;
  final String? name;

  Equipment({
    this.id,
    this.identifier,
    this.name,
  });

  factory Equipment.fromJson(Map<String, dynamic> parsedJson) {
    return Equipment(
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

class EquipmentPaginated extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<Equipment>? results;

  EquipmentPaginated({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory EquipmentPaginated.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Equipment> results = list.map((i) => Equipment.fromJson(i)).toList();

    return EquipmentPaginated(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class LocationResult {
  final int? id;
  final String? name;

  LocationResult({
    this.id,
    this.name
  });

  factory LocationResult.fromJson(Map<String, dynamic> parsedJson) {
    return LocationResult(
      id: parsedJson['id'],
      name: parsedJson['name'],
    );
  }
}

class EquipmentTypeAheadModel {
  final int? id;
  final String? name;
  final String? identifier;
  final String? description;
  final String? value;
  final LocationResult? location;

  EquipmentTypeAheadModel({
    this.id,
    this.name,
    this.identifier,
    this.description,
    this.value,
    this.location
  });

  factory EquipmentTypeAheadModel.fromJson(Map<String, dynamic> parsedJson) {
    LocationResult? location = parsedJson['location'] != null ? LocationResult.fromJson(parsedJson['location']) : null;

    return EquipmentTypeAheadModel(
      id: parsedJson['id'],
      name: parsedJson['name'],
      identifier: parsedJson['identifier'],
      description: parsedJson['description'],
      value: parsedJson['value'],
      location: location
    );
  }
}


abstract class BaseEquipmentCreateQuick extends BaseModel {
  final int? id;
  final String? name;

  BaseEquipmentCreateQuick({
    this.id,
    this.name,
  });
}

class EquipmentCreateQuickCustomer extends BaseEquipmentCreateQuick {
  final int? id;
  final String? name;
  final int? customer;

  EquipmentCreateQuickCustomer({
    this.id,
    required this.name,
    required this.customer
  });

  factory EquipmentCreateQuickCustomer.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentCreateQuickCustomer(
      id: parsedJson['id'],
      name: parsedJson['name'],
      customer: parsedJson['customer'],
    );
  }

  Map toMap() {
    return {
      'name': this.name,
      'customer': this.customer,
    };
  }

  @override
  String toJson() {
    return json.encode(toMap());
  }
}

class EquipmentCreateQuickBranch extends BaseEquipmentCreateQuick {
  final int? id;
  final String? name;
  final int? branch;

  EquipmentCreateQuickBranch({
    this.id,
    required this.name,
    required this.branch
  });

  factory EquipmentCreateQuickBranch.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentCreateQuickBranch(
      id: parsedJson['id'],
      name: parsedJson['name'],
      branch: parsedJson['branch'],
    );
  }

  Map toMap() {
    return {
      'name': this.name,
      'branch': this.branch,
    };
  }

  @override
  String toJson() {
    return json.encode(toMap());
  }
}

class EquipmentCreateQuickResponse extends BaseModel {
  final int? id;
  final String? name;

  EquipmentCreateQuickResponse({
    this.id,
    this.name,
  });

  factory EquipmentCreateQuickResponse.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentCreateQuickResponse(
      id: parsedJson['id'],
      name: parsedJson['name'],
    );
  }

  @override
  String toJson() {
    return '';
  }
}
