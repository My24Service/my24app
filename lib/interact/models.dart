import 'package:flutter/material.dart';

import 'package:my24_flutter_member_models/public/models.dart';

class PreferencesPageData {
  final String? memberPicture;
  final Members members;
  final Widget? drawer;

  PreferencesPageData({
    required this.memberPicture,
    required this.members,
    required this.drawer,
  });
}

class PreferencesFormData {
  String? preferredMemberCompanyCode;
  int? preferredMemberPk;
  String? preferredLanguageCode;
  bool? skipMemberList = false;

  PreferencesFormData({
    this.preferredMemberCompanyCode,
    this.preferredMemberPk,
    this.preferredLanguageCode,
    this.skipMemberList
  });
}
