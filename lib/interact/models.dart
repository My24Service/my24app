import 'package:flutter/material.dart';

import '../member/models/public/models.dart';

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
  String? preferedMemberCompanyCode;
  int? preferedMemberPk;
  String? preferedLanguageCode;
  bool? skipMemberList = false;

  PreferencesFormData({
    this.preferedMemberCompanyCode,
    this.preferedMemberPk,
    this.preferedLanguageCode,
    this.skipMemberList
  });
}
