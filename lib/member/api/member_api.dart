import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MemberApi {
  final _httpClient = new http.Client();

  Future<MemberPublic> fetchMember(http.Client client) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int memberPk = prefs.getInt('member_pk');

    var url = await getUrl('/member/detail-public/$memberPk/');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      return MemberPublic.fromJson(json.decode(response.body));
    }

    throw Exception('member_detail.exception_fetch'.tr());
  }

  Future<Members> fetchMembers(http.Client client) async {
    var url = await getUrl('/member/list-public/');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      return Members.fromJson(json.decode(response.body));
    }

    throw Exception('main.error_loading'.tr());
  }

  Future<String> getUrl(String path) async {
    final prefs = await SharedPreferences.getInstance();
    String companycode = prefs.getString('companycode');
    String apiBaseUrl = prefs.getString('apiBaseUrl');

    if (companycode == null || companycode == '' || companycode == 'jansenit') {
      companycode = 'demo';
    }

    if (apiBaseUrl == null || apiBaseUrl == '') {
      apiBaseUrl = 'my24service-dev.com';
    }

    return 'https://$companycode.$apiBaseUrl$path';
  }
}

MemberApi api = MemberApi();
