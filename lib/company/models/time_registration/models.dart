import 'package:flutter/cupertino.dart';

import 'package:my24_flutter_core/models/base_models.dart';

class TimeRegistrationPageData {
  final String? memberPicture;
  final bool isPlanning;
  final Widget? drawer;

  TimeRegistrationPageData({
    required this.memberPicture,
    required this.isPlanning,
    required this.drawer,
  });
}

class FieldTotalsString {
  final String? total;
  final String? intervalTotal;

  FieldTotalsString({
    this.total,
    this.intervalTotal
  });

  factory FieldTotalsString.fromJson(Map<String, dynamic> parsedJson) {
    return FieldTotalsString(
      total: parsedJson['total'],
      intervalTotal: parsedJson['interval_total'],
    );
  }

}

class FieldTotalsInt {
  final int? total;
  final int? intervalTotal;

  FieldTotalsInt({
    this.total,
    this.intervalTotal
  });

  factory FieldTotalsInt.fromJson(Map<String, dynamic> parsedJson) {
    return FieldTotalsInt(
      total: parsedJson['total'],
      intervalTotal: parsedJson['interval_total'],
    );
  }
}

class TimeTotals extends BaseModel {
  final DateTime? bucket;
  final String? fullName;
  final int? userId;
  final int? interval;
  final double? contractHoursWeek;
  final FieldTotalsString? workTotal;
  final FieldTotalsString? travelTotal;
  final FieldTotalsInt? distanceTotal;
  final FieldTotalsString? extraWork;
  final FieldTotalsString? actualWork;

  getValueByKey(String key) {
    switch (key) {
      case "work_total":
        {
          return this.workTotal;
        }

      case "travel_total":
        {
          return this.travelTotal;
        }

      case "distance_total":
        {
          return this.distanceTotal;
        }

      case "extra_work":
        {
          return this.extraWork;
        }

      case "actual_work":
        {
          return this.actualWork;
        }

      default:
        {
          throw Exception("unknown annotation field: $key");
        }
    }
  }

  TimeTotals({
    this.bucket,
    this.fullName,
    this.userId,
    this.interval,
    this.contractHoursWeek,
    this.workTotal,
    this.travelTotal,
    this.distanceTotal,
    this.extraWork,
    this.actualWork
  });

  factory TimeTotals.fromJson(Map<String, dynamic> parsedJson) {
    DateTime bucket = DateTime.parse(parsedJson['bucket']);

    FieldTotalsString? workTotal = parsedJson['work_total'] == null ? null :
      FieldTotalsString.fromJson(parsedJson['work_total']);

    FieldTotalsString? travelTotal = parsedJson['travel_total'] == null ? null :
      FieldTotalsString.fromJson(parsedJson['travel_total']);

    FieldTotalsInt? distanceTotal = parsedJson['distance_total'] == null ? null :
      FieldTotalsInt.fromJson(parsedJson['distance_total']);

    FieldTotalsString? extraWork = parsedJson['extra_work'] == null ? null :
      FieldTotalsString.fromJson(parsedJson['extra_work']);

    FieldTotalsString? actualWork = parsedJson['actual_work'] == null ? null :
      FieldTotalsString.fromJson(parsedJson['actual_work']);

    return TimeTotals(
      bucket: bucket,
      fullName: parsedJson['full_name'],
      userId: parsedJson['user_id'],
      interval: parsedJson['interval'],
      contractHoursWeek: parsedJson['contract_hours_week'] == null ? 0 : parsedJson['contract_hours_week'].toDouble(),
      workTotal: workTotal,
      travelTotal: travelTotal,
      distanceTotal: distanceTotal,
      extraWork: extraWork,
      actualWork: actualWork
    );
  }

  @override
  String toJson() {
    throw UnimplementedError();
  }
}

class WorkHourData extends BaseModel {
  final String? date;
  final String? username;
  final String? source;
  final String? description;
  final String? workStart;
  final String? workEnd;
  final String? travelTo;
  final String? travelBack;
  final int? distanceTo;
  final int? distanceBack;
  final String? extraWork;
  final String? actualWork;

  WorkHourData({
    this.date,
    this.username,
    this.source,
    this.description,
    this.workStart,
    this.workEnd,
    this.travelTo,
    this.travelBack,
    this.distanceTo,
    this.distanceBack,
    this.extraWork,
    this.actualWork,
  });

  factory WorkHourData.fromJson(Map<String, dynamic> parsedJson) {
    return WorkHourData(
      date: parsedJson['date'],
      username: parsedJson['username'],
      source: parsedJson['source'],
      description: parsedJson['description'],
      workStart: parsedJson['work_start'],
      workEnd: parsedJson['work_end'],
      travelTo: parsedJson['travel_to'],
      travelBack: parsedJson['travel_back'],
      distanceTo: parsedJson['distance_to'],
      distanceBack: parsedJson['distance_back'],
      extraWork: parsedJson['extra_work'],
      actualWork: parsedJson['actual_work'],
    );
  }

  @override
  String toJson() {
    throw UnimplementedError();
  }
}

class LeaveData extends BaseModel {
  final String? date;
  final String? username;
  final String? leaveType;
  final String? leaveDuration;

  LeaveData({
    this.date,
    this.username,
    this.leaveType,
    this.leaveDuration,
  });

  factory LeaveData.fromJson(Map<String, dynamic> parsedJson) {
    return LeaveData(
      date: parsedJson['date'],
      username: parsedJson['username'],
      leaveType: parsedJson['leave_type'],
      leaveDuration: parsedJson['leave_duration'],
    );
  }

  @override
  String toJson() {
    throw UnimplementedError();
  }
}

class TimeRegistration extends BaseModelPagination  {
  final String? fullName;
  final List<int>? intervals;
  final List<String>? totalsFields;
  final List<DateTime>? dateList;
  final List<TimeTotals>? totals;
  final List<WorkHourData>? workhourData;
  final List<LeaveData>? leaveData;

  TimeRegistration({
    this.fullName,
    this.intervals,
    this.totalsFields,
    this.dateList,
    this.totals,
    this.workhourData,
    this.leaveData
  });

  factory TimeRegistration.fromJson(Map<String, dynamic> parsedJson) {
    var dateListList = parsedJson['date_list'] as List;
    List<DateTime> dateList = dateListList.map((i) => DateTime.parse(i)).toList();

    var totalsList = parsedJson['totals'] as List;
    List<TimeTotals> totals = totalsList.map((i) => TimeTotals.fromJson(i)).toList();

    List<WorkHourData> workhourData = [];
    if (parsedJson['workhour_data'] != null) {
      var workhourDataList = parsedJson['workhour_data'] as List;
      workhourData = workhourDataList.map((i) => WorkHourData.fromJson(i)).toList();
    }

    List<LeaveData> leaveData = [];
    if (parsedJson['leave_data'] != null) {
      var leaveDataList = parsedJson['leave_data'] as List;
      leaveData = leaveDataList.map((i) => LeaveData.fromJson(i)).toList();
    }

    var intervalsList = parsedJson['intervals'] as List;
    List<int> intervals = intervalsList.map((i) => i as int).toList();

    var totalsFieldsList = parsedJson['totals_fields'] as List;
    List<String> totalsFields = totalsFieldsList.map((i) => "$i").toList();

    return TimeRegistration(
      fullName: parsedJson['full_name'],
      dateList: dateList,
      intervals: intervals,
      totalsFields: totalsFields,
      totals: totals,
      workhourData: workhourData,
      leaveData: leaveData
    );
  }
}

class TimeRegistrationDummy extends BaseModel {
  factory TimeRegistrationDummy.fromJson(Map<String, dynamic> parsedJson) {
    throw UnimplementedError();
  }

  @override
  String toJson() {
    throw UnimplementedError();
  }
}
