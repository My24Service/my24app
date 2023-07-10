import 'dart:async';
import 'dart:convert';

import 'package:my24app/core/api/base_crud.dart';
import 'models.dart';

class UserLeaveHoursApi extends BaseCrud<UserLeaveHours, UserLeaveHoursPaginated> {
  final String basePath = "/company/user-leave-hours";

  @override
  UserLeaveHours fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return UserLeaveHours.fromJson(parsedJson!);
  }

  @override
  UserLeaveHoursPaginated fromJsonList(Map<String, dynamic>? parsedJson) {
    return UserLeaveHoursPaginated.fromJson(parsedJson!);
  }

  Future<UserLeaveHoursPaginated> fetchUnaccepted({ query = '', page = 1}) async {
    return super.list(
        filters: { 'q': query, 'page': page },
        basePathAddition: 'all_not_accepted/');
  }

  Future<int> fetchUnacceptedCount() async {
    final String responseBody = await super.getListResponseBody(
        basePathAddition: 'all_not_accepted_count/');

    final Map<String, dynamic> response = json.decode(responseBody);

    return int.parse("${response['count']}");
  }

  Future<LeaveHoursData> getTotals(UserLeaveHours hours) async {
    dynamic response = await (this.insertCustom(
        hours.asMap(),
        'get_totals/',
        returnTypeBool: false
    ));

    return LeaveHoursData.fromJson(response);
  }

}

class UserLeaveHoursPlanningApi extends BaseCrud<UserLeaveHours, UserLeaveHoursPaginated> {
  final String basePath = "/company/user-leave-hours/admin";

  @override
  UserLeaveHours fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return UserLeaveHours.fromJson(parsedJson!);
  }

  @override
  UserLeaveHoursPaginated fromJsonList(Map<String, dynamic>? parsedJson) {
    return UserLeaveHoursPaginated.fromJson(parsedJson!);
  }

  Future<bool> reject(int leavePk) async {
    final Map body = {};
    String basePathAddition = '$leavePk/set_rejected/';
    return await super.insertCustom(body, basePathAddition);
  }

  Future<bool> accept(int leavePk) async {
    final Map body = {};
    String basePathAddition = '$leavePk/set_accepted/';
    return await super.insertCustom(body, basePathAddition);
  }

  Future<LeaveHoursData> getTotals(UserLeaveHours hours) async {
    dynamic response = await this.insertCustom(
        hours.asMap(),
        'get_totals/',
        returnTypeBool: false
    );

    return LeaveHoursData.fromJson(response);
  }

  Future<UserLeaveHoursPaginated> fetchUnaccepted({ query = '', page = 1}) async {
    return super.list(
        filters: { 'q': query, 'page': page },
        basePathAddition: 'all_not_accepted/');
  }

  Future<int> fetchUnacceptedCount() async {
    final String responseBody = await super.getListResponseBody(
        basePathAddition: 'all_not_accepted_count/');

    final Map<String, dynamic> response = json.decode(responseBody);

    return int.parse("${response['count']}");
  }
}
