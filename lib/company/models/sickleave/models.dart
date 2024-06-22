import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:my24_flutter_core/models/base_models.dart';

class UserSickLeavePageData {
  final String? memberPicture;
  final bool isPlanning;
  final Widget? drawer;

  UserSickLeavePageData({
    required this.memberPicture,
    required this.isPlanning,
    required this.drawer,
  });
}

class UserSickLeave extends BaseModel  {
  final int? id;
  final String? fullName;
  final String? startDate;
  final String? endDate;
  final String? lastStatus;
  final String? lastStatusFull;

  UserSickLeave({
    this.id,
    this.fullName,
    this.startDate,
    this.endDate,
    this.lastStatus,
    this.lastStatusFull,
  });

  factory UserSickLeave.fromJson(Map<String, dynamic> parsedJson) {
    return UserSickLeave(
      id: parsedJson['id'],
      fullName: parsedJson['full_name'],
      startDate: parsedJson['start_date'],
      endDate: parsedJson['end_date'],
      lastStatus: parsedJson['last_status'],
      lastStatusFull: parsedJson['last_status_full'],
    );
  }

  Map asMap() {
    final Map body = {
      'start_date': startDate,
      'end_date': endDate,
    };

    return body;
  }

  @override
  String toJson() {
    final Map body = asMap();
    return json.encode(body);
  }
}

class UserSickLeavePaginated extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<UserSickLeave>? results;

  UserSickLeavePaginated({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory UserSickLeavePaginated.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<UserSickLeave> results = list.map((i) => UserSickLeave.fromJson(i)).toList();

    return UserSickLeavePaginated(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}
