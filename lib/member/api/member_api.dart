import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/member/models/models.dart';

class MemberApi with ApiMixin {
  final _httpClient = new http.Client();

  Future<MemberPublic> fetchMember() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int memberPk = prefs.getInt('member_pk');

    var url = await getUrl('/member/detail-public/$memberPk/');
    final response = await _httpClient.get(url);

    if (response.statusCode == 200) {
      return MemberPublic.fromJson(json.decode(response.body));
    }

    throw Exception('member_detail.exception_fetch'.tr());
  }

  Future<Members> fetchMembers(http.Client client) async {
    var url = await getUrl('/member/list-public/');
    final response = await _httpClient.get(url);

    if (response.statusCode == 200) {
      return Members.fromJson(json.decode(response.body));
    }

    throw Exception('main.error_loading'.tr());
  }

}

MemberApi memberApi = MemberApi();
