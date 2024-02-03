import 'dart:convert';

import 'package:my24_flutter_core/models/base_models.dart';

class Infoline extends BaseModel {
  final int? id;
  int? order;
  final String? info;

  Infoline({
    this.id,
    this.order,
    this.info,
  });

  factory Infoline.fromJson(Map<String, dynamic> parsedJson) {
    return Infoline(
      id: parsedJson['id'],
      order: parsedJson['order'],
      info: parsedJson['info'],
    );
  }

  @override
  String toJson() {
    Map body = {
      'id': this.id,
      'order': this.order,
      'info': this.info,
    };

    return json.encode(body);
  }
}

class Infolines extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<Infoline>? results;

  Infolines({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Infolines.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Infoline> results = list.map((i) => Infoline.fromJson(i)).toList();

    return Infolines(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}
