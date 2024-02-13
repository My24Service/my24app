import 'package:my24_flutter_member_models/public/models.dart';

class MemberDetailData {
  final bool? isLoggedIn;
  final String? submodel;
  final Member? member;

  MemberDetailData({
    this.isLoggedIn,
    this.submodel,
    this.member,
  });
}
