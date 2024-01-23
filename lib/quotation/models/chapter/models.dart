import 'dart:convert';

import 'package:my24app/core/models/base_models.dart';

class Chapter extends BaseModel {
  final int? id;
  final int? quotation;
  final String? name;
  final String? description;

  Chapter({this.id, this.quotation, this.name, this.description});

  factory Chapter.fromJson(Map<String, dynamic> parsedJson) {
    return Chapter(
        id: parsedJson['id'],
        quotation: parsedJson['quotation'],
        name: parsedJson['name'],
        description: parsedJson['description']);
  }

  @override
  String toJson() {
    final Map<String, dynamic> body = {
      'quotation': quotation,
      'name': name,
      'description': description
    };

    return json.encode(body);
  }
}

class Chapters extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<Chapter>? results;

  Chapters({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Chapters.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Chapter> results = list.map((i) => Chapter.fromJson(i)).toList();

    return Chapters(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}
