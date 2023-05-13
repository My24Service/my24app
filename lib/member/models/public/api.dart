import 'package:my24app/core/api/base_crud.dart';
import 'models.dart';

class MemberListPublicApi extends BaseCrud<Member, Members> {
  final String basePath = "/member/list-public";

  @override
  Member fromJsonDetail(Map<String, dynamic> parsedJson) {
    return Member.fromJson(parsedJson);
  }

  @override
  Members fromJsonList(Map<String, dynamic> parsedJson) {
    return Members.fromJson(parsedJson);
  }
}

class MemberDetailPublicApi extends BaseCrud<Member, Members> {
  final String basePath = "/member/detail-public";

  @override
  Member fromJsonDetail(Map<String, dynamic> parsedJson) {
    return Member.fromJson(parsedJson);
  }

  @override
  Members fromJsonList(Map<String, dynamic> parsedJson) {
    return Members.fromJson(parsedJson);
  }
}
