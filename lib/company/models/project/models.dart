import 'dart:convert';

import 'package:my24_flutter_core/models/base_models.dart';

class Project extends BaseModel  {
  final int? id;
  final String? name;

  Project({
    this.id,
    this.name
  });

  factory Project.fromJson(Map<String, dynamic> parsedJson) {
    return Project(
      id: parsedJson['id'],
      name: parsedJson['name'],
    );
  }

  String toJson() {
    Map body = {
      'name': this.name,
    };

    return json.encode(body);
  }
}

class Projects extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<Project>? results;

  Projects({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Projects.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Project> results = list.map((i) => Project.fromJson(i)).toList();

    return Projects(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}
