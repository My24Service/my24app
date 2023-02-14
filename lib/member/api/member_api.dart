import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/member/models/models.dart';

class MemberApi with ApiMixin {
  // default and settable for tests
  http.Client _httpClient = new http.Client();
  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Utils localUtils = utils;

  Future<MemberPublic> fetchMember(int memberPk) async {
    var url = await getUrl('/member/detail-public/$memberPk/');
    final response = await _httpClient.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return MemberPublic.fromJson(json.decode(response.body));
    }

    throw Exception('member_detail.exception_fetch'.tr());
  }

  Future<Members> fetchMembers() async {
    var url = await getUrl('/member/list-public/');
    final response = await _httpClient.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Members.fromJson(json.decode(response.body));
    }

    throw Exception('main.error_loading'.tr());
  }

  Future<PicturesPublic> fetchPictures() async {
    var url = await getUrl('/company/public-pictures/');
    final response = await _httpClient.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return PicturesPublic.fromJson(json.decode(response.body));
    }

    return null;
  }
}

MemberApi memberApi = MemberApi();
