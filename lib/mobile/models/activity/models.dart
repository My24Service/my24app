
import 'dart:convert';

import '../../../core/models/base_models.dart';

class AssignedOrderActivity extends BaseModel  {
  final int id;
  final String activityDate;
  final int assignedOrderId;
  final String workStart;
  final String workEnd;
  final String travelTo;
  final String travelBack;
  final int odoReadingToStart;
  final int odoReadingToEnd;
  final int odoReadingBackStart;
  final int odoReadingBackEnd;
  final int distanceTo;
  final int distanceBack;
  final String extraWork;
  final String extraWorkDescription;
  final String fullName;
  final String actualWork;

  AssignedOrderActivity({
    this.id,
    this.activityDate,
    this.assignedOrderId,
    this.workStart,
    this.workEnd,
    this.travelTo,
    this.travelBack,
    this.odoReadingToStart,
    this.odoReadingToEnd,
    this.odoReadingBackStart,
    this.odoReadingBackEnd,
    this.distanceTo,
    this.distanceBack,
    this.extraWork,
    this.extraWorkDescription,
    this.fullName,
    this.actualWork,
  });

  factory AssignedOrderActivity.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrderActivity(
      id: parsedJson['id'],
      assignedOrderId: parsedJson['assigned_order'],
      activityDate: parsedJson['activity_date'],
      workStart: parsedJson['work_start'],
      workEnd: parsedJson['work_end'],
      travelTo: parsedJson['travel_to'],
      travelBack: parsedJson['travel_back'],
      odoReadingToStart: parsedJson['odo_reading_to_start'],
      odoReadingToEnd: parsedJson['odo_reading_to_end'],
      odoReadingBackStart: parsedJson['odo_reading_back_start'],
      odoReadingBackEnd: parsedJson['odo_reading_back_end'],
      distanceTo: parsedJson['distance_to'],
      distanceBack: parsedJson['distance_back'],
      extraWork: parsedJson['extra_work'],
      extraWorkDescription: parsedJson['extra_work_description'],
      fullName: parsedJson['full_name'],
      actualWork: parsedJson['actual_work'],
    );
  }

  String toJson() {
    Map body = {
      'activity_date': this.activityDate,
      'assigned_order': this.assignedOrderId,
      'distance_to': this.distanceTo,
      'distance_back': this.distanceBack,
      'travel_to': this.travelTo,
      'travel_back': this.travelBack,
      'work_start': this.workStart,
      'work_end': this.workEnd,
      'extra_work': this.extraWork,
      'extra_work_description': this.extraWorkDescription,
      'actual_work': this.actualWork,
    };

    return json.encode(body);
  }
}

class AssignedOrderActivities extends BaseModelPagination {
  final int count;
  final String next;
  final String previous;
  final List<AssignedOrderActivity> results;

  AssignedOrderActivities({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory AssignedOrderActivities.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<AssignedOrderActivity> results = list.map((i) => AssignedOrderActivity.fromJson(i)).toList();

    return AssignedOrderActivities(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}