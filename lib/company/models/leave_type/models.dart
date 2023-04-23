import 'dart:convert';

import 'package:my24app/core/models/base_models.dart';

class LeaveType extends BaseModel  {
  final int id;
  final String name;
  final bool countsAsLeave;

  LeaveType({
    this.id,
    this.name,
    this.countsAsLeave
  });

  factory LeaveType.fromJson(Map<String, dynamic> parsedJson) {
    return LeaveType(
      id: parsedJson['id'],
      name: parsedJson['name'],
      countsAsLeave: parsedJson['counts_as_leave'],
    );
  }

  String toJson() {
    Map body = {
      'name': this.name,
      'counts_as_leave': this.countsAsLeave
    };

    return json.encode(body);
  }
}

class LeaveTypes extends BaseModelPagination {
  final int count;
  final String next;
  final String previous;
  final List<LeaveType> results;

  LeaveTypes({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory LeaveTypes.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<LeaveType> results = list.map((i) => LeaveType.fromJson(i)).toList();

    return LeaveTypes(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}
