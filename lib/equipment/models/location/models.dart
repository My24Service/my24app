import 'dart:convert';

import 'package:my24_flutter_core/models/base_models.dart';

class EquipmentLocation extends BaseModel {
  final int? id;
  final String? identifier;
  final String? name;

  EquipmentLocation({
    this.id,
    this.identifier,
    this.name,
  });

  static List<EquipmentLocation> getListFromResponse(String response) {
    var list = json.decode(response) as List;

    return list.map((i) => EquipmentLocation.fromJson(i)).toList();
  }

  factory EquipmentLocation.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentLocation(
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

class EquipmentLocations extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<EquipmentLocation>? results;

  EquipmentLocations({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory EquipmentLocations.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<EquipmentLocation> results = list.map((i) => EquipmentLocation.fromJson(i)).toList();

    return EquipmentLocations(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class EquipmentLocationTypeAheadModel {
  final int? id;
  final String? name;
  final String? identifier;
  final String? value;

  EquipmentLocationTypeAheadModel({
    this.id,
    this.name,
    this.identifier,
    this.value,
  });

  factory EquipmentLocationTypeAheadModel.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentLocationTypeAheadModel(
      id: parsedJson['id'],
      name: parsedJson['name'],
      identifier: parsedJson['identifier'],
      value: parsedJson['value'],
    );
  }
}


abstract class BaseEquipmentLocationCreateQuick extends BaseModel {
  final int? id;
  final String? name;

  BaseEquipmentLocationCreateQuick({
    this.id,
    this.name,
  });
}

class EquipmentLocationCreateQuickCustomer extends BaseEquipmentLocationCreateQuick {
  final int? id;
  final String? name;
  final int? customer;

  EquipmentLocationCreateQuickCustomer({
    this.id,
    required this.name,
    required this.customer
  });

  factory EquipmentLocationCreateQuickCustomer.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentLocationCreateQuickCustomer(
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

class EquipmentLocationCreateQuickBranch extends BaseEquipmentLocationCreateQuick {
  final int? id;
  final String? name;
  final int? branch;

  EquipmentLocationCreateQuickBranch({
    this.id,
    required this.name,
    required this.branch
  });

  factory EquipmentLocationCreateQuickBranch.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentLocationCreateQuickBranch(
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

class EquipmentLocationCreateQuickResponse extends BaseModel {
  final int? id;
  final String? name;

  EquipmentLocationCreateQuickResponse({
    this.id,
    this.name,
  });

  factory EquipmentLocationCreateQuickResponse.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentLocationCreateQuickResponse(
      id: parsedJson['id'],
      name: parsedJson['name'],
    );
  }

  @override
  String toJson() {
    return '';
  }
}
