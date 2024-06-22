import 'dart:convert';

import 'package:my24_flutter_core/models/base_models.dart';

class AssignedOrderDocument extends BaseModel {
  final int? id;
  final int? assignedOrderId;
  final String? name;
  final String? description;
  final String? document;

  AssignedOrderDocument({
    this.id,
    this.assignedOrderId,
    this.name,
    this.description,
    this.document,
  });

  factory AssignedOrderDocument.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrderDocument(
      id: parsedJson['id'],
      assignedOrderId: parsedJson['assigned_order'],
      name: parsedJson['name'],
      description: parsedJson['description'],
      document: parsedJson['document'],
    );
  }

  @override
  String toJson() {
    final Map body = {
      'assigned_order': assignedOrderId,
      'name': name,
      'description': description,
      'document': document,
    };

    return json.encode(body);
  }
}

class AssignedOrderDocuments extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<AssignedOrderDocument>? results;

  AssignedOrderDocuments({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory AssignedOrderDocuments.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<AssignedOrderDocument> results = list.map((i) => AssignedOrderDocument.fromJson(i)).toList();

    return AssignedOrderDocuments(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}
