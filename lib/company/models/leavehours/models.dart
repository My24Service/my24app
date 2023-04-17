import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:my24app/core/models/base_models.dart';

class UserLeaveHoursPageData {
  final String memberPicture;
  final bool isPlanning;
  final Widget drawer;

  UserLeaveHoursPageData({
    @required this.memberPicture,
    @required this.isPlanning,
    @required this.drawer,
  });
}

class UserLeaveHours extends BaseModel  {
  final int id;
  final int leaveType;
  final String leaveTypeName;
  final String fullName;

  final String startDate;
  final int startDateHours;
  final int startDateMinutes;
  final bool startDateIsWholeDay;
  final String endDate;
  final int endDateHours;
  final int endDateMinutes;
  final bool endDateIsWholeDay;

  final int totalHours;
  final int totalMinutes;

  final int contractHoursUsed;

  final bool isAccepted;
  final bool isRejected;

  final String description;

  final String lastStatus;
  final String lastStatusFull;

  UserLeaveHours({
    this.id,
    this.leaveType,
    this.leaveTypeName,
    this.fullName,

    this.startDate,
    this.startDateHours,
    this.startDateMinutes,
    this.startDateIsWholeDay,
    this.endDate,
    this.endDateHours,
    this.endDateMinutes,
    this.endDateIsWholeDay,

    this.totalHours,
    this.totalMinutes,

    this.contractHoursUsed,

    this.isAccepted,
    this.isRejected,

    this.description,

    this.lastStatus,
    this.lastStatusFull,
  });

  factory UserLeaveHours.fromJson(Map<String, dynamic> parsedJson) {
    return UserLeaveHours(
      id: parsedJson['id'],
      leaveType: parsedJson['leave_type'],
      leaveTypeName: parsedJson['leave_type_name'],
      fullName: parsedJson['full_name'],
      startDate: parsedJson['start_date'],
      startDateHours: parsedJson['start_date_hours'],
      startDateMinutes: parsedJson['start_date_minutes'],
      startDateIsWholeDay: parsedJson['start_date_is_whole_day'],
      endDate: parsedJson['end_date'],
      endDateHours: parsedJson['end_date_hours'],
      endDateMinutes: parsedJson['end_date_minutes'],
      endDateIsWholeDay: parsedJson['end_date_is_whole_day'],
      totalHours: parsedJson['total_hours'],
      totalMinutes: parsedJson['total_minutes'],
      contractHoursUsed: parsedJson['contract_hours_used'],
      isAccepted: parsedJson['is_accepted'],
      isRejected: parsedJson['is_rejected'],
      description: parsedJson['description'],
      lastStatus: parsedJson['last_status'],
      lastStatusFull: parsedJson['last_status_full'],
    );
  }

  @override
  String toJson() {
    final Map body = {
      'leave_type': leaveType,
      'start_date': startDate,
      'start_date_hours': startDateHours,
      'start_date_minutes': startDateMinutes,
      'start_date_is_whole_day': startDateIsWholeDay,
      'end_date': endDate,
      'end_date_hours': endDateHours,
      'end_date_minutes': endDateMinutes,
      'end_date_is_whole_day': endDateIsWholeDay,
      'total_hours': totalHours,
      'total_minutes': totalMinutes,
      'contract_hours_used': contractHoursUsed,
      'description': description,
    };

    return json.encode(body);
  }
}

class UserLeaveHoursPaginated extends BaseModelPagination {
  final int count;
  final String next;
  final String previous;
  final List<UserLeaveHours> results;

  UserLeaveHoursPaginated({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory UserLeaveHoursPaginated.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<UserLeaveHours> results = list.map((i) => UserLeaveHours.fromJson(i)).toList();

    return UserLeaveHoursPaginated(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}
