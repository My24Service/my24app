import 'dart:convert';

import 'package:my24app/core/api/base_crud.dart';
import 'models.dart';

class PrivateMemberApi extends BaseCrud<PrivateMember, PrivateMembers> {
  final String basePath = "/member/member";

  @override
  PrivateMember fromJsonDetail(Map<String, dynamic> parsedJson) {
    return PrivateMember.fromJson(parsedJson);
  }

  @override
  PrivateMembers fromJsonList(Map<String, dynamic> parsedJson) {
    return PrivateMembers.fromJson(parsedJson);
  }

  Future<Map<String, dynamic>> fetchSettings() async {
    final String response = await super.getListResponseBody(
        basePathAddition: 'get_my_settings/');

    return json.decode(response);
  }
}
