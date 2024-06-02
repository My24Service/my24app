import 'dart:async';
import 'dart:convert';

import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class UserSickLeaveApi extends BaseCrud<UserSickLeave, UserSickLeavePaginated> {
  final String basePath = "/company/user-sick-leave";

  @override
  UserSickLeave fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return UserSickLeave.fromJson(parsedJson!);
  }

  @override
  UserSickLeavePaginated fromJsonList(Map<String, dynamic>? parsedJson) {
    return UserSickLeavePaginated.fromJson(parsedJson!);
  }

  Future<bool> EndSick() async {
    final Map body = {};
    String basePathAddition = 'end_sick/';
    return await super.insertCustom(body, basePathAddition);
  }
}

class UserSickLeavePlanningApi extends BaseCrud<UserSickLeave, UserSickLeavePaginated> {
  final String basePath = "/company/user-sick-leave/admin";

  @override
  UserSickLeave fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return UserSickLeave.fromJson(parsedJson!);
  }

  @override
  UserSickLeavePaginated fromJsonList(Map<String, dynamic>? parsedJson) {
    return UserSickLeavePaginated.fromJson(parsedJson!);
  }

  Future<bool> setConfirmed(int leavePk) async {
    final Map body = {};
    String basePathAddition = '$leavePk/set_confirmed/';
    return await super.insertCustom(body, basePathAddition);
  }

  Future<bool> EndSick(int leavePk) async {
    final Map body = {};
    String basePathAddition = '$leavePk/end_sick/';
    return await super.insertCustom(body, basePathAddition);
  }

  Future<UserSickLeavePaginated> fetchUnconfirmed({ query = '', page = 1}) async {
    return super.list(
        filters: { 'q': query, 'page': page },
        basePathAddition: 'all_unconfirmed/');
  }

  Future<int> fetchUnseenCount() async {
    final String responseBody = await super.getListResponseBody(
        basePathAddition: 'all_unconfirmed_count/');

    final Map<String, dynamic> response = json.decode(responseBody);

    return int.parse("${response['count']}");
  }
}
