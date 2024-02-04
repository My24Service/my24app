import 'dart:convert';

import 'package:my24_flutter_core/api/base_crud.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'models.dart';

class MemberListPublicApi extends BaseCrud<Member, Members> {
  final String basePath = "/member/list-public";

  @override
  Member fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Member.fromJson(parsedJson!);
  }

  @override
  Members fromJsonList(Map<String, dynamic>? parsedJson) {
    return Members.fromJson(parsedJson!);
  }
}

class MemberDetailPublicApi extends BaseCrud<Member, Members> {
  final String basePath = "/member/detail-public"; //current-detail-public

  @override
  Member fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Member.fromJson(parsedJson!);
  }

  @override
  Members fromJsonList(Map<String, dynamic>? parsedJson) {
    return Members.fromJson(parsedJson!);
  }
}

class MemberByCompanycodePublicApi extends BaseCrud<Member, Members> {
  final String basePath = "/member/detail-public-companycode";


  Future<Member> get(String companycode) async {
    Map<String, String> headers = {};

    String url = await getUrl('$basePath/$companycode/');

    final response = await httpClient.get(
        Uri.parse(url),
        headers: headers
    );

    if (response.statusCode == 200) {
      return fromJsonDetail(json.decode(response.body));
    }

    final String errorMsg = getTranslationTr('generic.exception_fetch_detail');
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  @override
  Member fromJsonDetail(Map<String, dynamic>? parsedJson) {
  return Member.fromJson(parsedJson!);
  }

  @override
  Members fromJsonList(Map<String, dynamic>? parsedJson) {
  return Members.fromJson(parsedJson!);
  }
}
