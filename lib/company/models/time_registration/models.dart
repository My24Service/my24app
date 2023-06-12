import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';

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

class TimeTotals extends BaseModel {
  final DateTime? bucket;
  final String? fullName;
  final int? userId;
  final double? contractHoursWeek;
  final Duration? workTotal;
  final Duration? travelTotal;
  final int? distanceTotal;
  final Duration? extraWork;
  final Duration? actualWork;

  getValueByString(String key) {
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
    this.contractHoursWeek,
    this.workTotal,
    this.travelTotal,
    this.distanceTotal,
    this.extraWork,
    this.actualWork
  });

  factory TimeTotals.fromJson(Map<String, dynamic> parsedJson) {
    DateTime bucket = DateTime.parse(parsedJson['bucket']);

    Duration? workTotal = parsedJson['work_total'] == null ? null :
      Duration(seconds: int.parse(parsedJson['work_total']));
    Duration? travelTotal = parsedJson['travel_total'] == null ? null :
      Duration(seconds: int.parse(parsedJson['travel_total']));
    Duration? extraWork = parsedJson['extra_work'] == null ? null :
      Duration(seconds: int.parse(parsedJson['extra_work']));
    Duration? actualWork = parsedJson['actual_work'] == null ? null :
    Duration(seconds: int.parse(parsedJson['actual_work']));

    return TimeTotals(
      bucket: bucket,
      fullName: parsedJson['full_name'],
      userId: parsedJson['user_id'],
      contractHoursWeek: parsedJson['contract_hours_week'],
      workTotal: workTotal,
      travelTotal: travelTotal,
      distanceTotal: parsedJson['distance_total'],
      extraWork: extraWork,
      actualWork: actualWork
    );
  }

  @override
  String toJson() {
    throw UnimplementedError();
  }
}

class TimeData extends BaseModel {
  final String? date;
  final String? username;
  final String? source;
  final String? projectName;
  final String? customerName;
  final String? workStart;
  final String? workEnd;
  final String? travelTo;
  final String? travelBack;
  final int? distanceTo;
  final int? distanceBack;
  final String? extraWork;
  final String? actualWork;

  TimeData({
    this.date,
    this.username,
    this.source,
    this.projectName,
    this.customerName,
    this.workStart,
    this.workEnd,
    this.travelTo,
    this.travelBack,
    this.distanceTo,
    this.distanceBack,
    this.extraWork,
    this.actualWork,
  });

  factory TimeData.fromJson(Map<String, dynamic> parsedJson) {
    return TimeData(
      date: parsedJson['date'],
      username: parsedJson['username'],
      source: parsedJson['source'],
      projectName: parsedJson['project_name'],
      customerName: parsedJson['customer_name'],
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

class TimeRegistration extends BaseModelPagination  {
  final String? fullName;
  final List<String>? fieldTypes;
  final List<String>? annotateFields;
  final List<DateTime>? dateList;
  final List<TimeTotals>? totals;
  final List<TimeData>? data;

  TimeRegistration({
    this.fullName,
    this.fieldTypes,
    this.annotateFields,
    this.dateList,
    this.totals,
    this.data
  });

  factory TimeRegistration.fromJson(Map<String, dynamic> parsedJson) {
    var dateListList = parsedJson['date_list'] as List;
    List<DateTime> dateList = dateListList.map((i) => DateTime.parse(i)).toList();

    var totalsList = parsedJson['totals'] as List;
    List<TimeTotals> totals = totalsList.map((i) => TimeTotals.fromJson(i)).toList();

    var dataList = parsedJson['data'] as List;
    List<TimeData> data = dataList.map((i) => TimeData.fromJson(i)).toList();

    return TimeRegistration(
      fullName: parsedJson['full_name'],
      fieldTypes: parsedJson['field_types'],
      annotateFields: parsedJson['annotate_fields'],
      dateList: dateList,
      totals: totals,
      data: data,
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
