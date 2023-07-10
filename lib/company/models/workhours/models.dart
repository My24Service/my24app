import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:my24app/core/models/base_models.dart';

class UserWorkHoursPageData {
  final String? memberPicture;
  final bool isPlanning;
  final Widget? drawer;

  UserWorkHoursPageData({
    required this.memberPicture,
    required this.isPlanning,
    required this.drawer,
  });
}

class UserWorkHours extends BaseModel  {
  final int? id;
  final int? project;
  final String? projectName;
  final String? fullName;
  final String? startDate;
  final String? workStart;
  final String? workEnd;
  final String? travelTo;
  final String? travelBack;
  final int? distanceTo;
  final int? distanceBack;
  final String? description;

  UserWorkHours({
    this.id,
    this.project,
    this.projectName,
    this.fullName,
    this.startDate,
    this.workStart,
    this.workEnd,
    this.travelTo,
    this.travelBack,
    this.distanceTo,
    this.distanceBack,
    this.description,
  });

  factory UserWorkHours.fromJson(Map<String, dynamic> parsedJson) {
    return UserWorkHours(
      id: parsedJson['id'],
      project: parsedJson['project'],
      projectName: parsedJson['project_name'],
      fullName: parsedJson['full_name'],
      startDate: parsedJson['start_date'],
      workStart: parsedJson['work_start'],
      workEnd: parsedJson['work_end'],
      travelTo: parsedJson['travel_to'],
      travelBack: parsedJson['travel_back'],
      distanceTo: parsedJson['distance_to'],
      distanceBack: parsedJson['distance_back'],
      description: parsedJson['description'],
    );
  }

  @override
  String toJson() {
    final Map body = {
      'project': project,
      'start_date': startDate,
      'distance_to': distanceTo,
      'distance_back': distanceBack,
      'travel_to': travelTo,
      'travel_back': travelBack,
      'work_start': workStart,
      'work_end': workEnd,
      'description': description,
    };

    return json.encode(body);
  }
}

class UserWorkHoursPaginated extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<UserWorkHours>? results;

  UserWorkHoursPaginated({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory UserWorkHoursPaginated.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<UserWorkHours> results = list.map((i) => UserWorkHours.fromJson(i)).toList();

    return UserWorkHoursPaginated(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}
