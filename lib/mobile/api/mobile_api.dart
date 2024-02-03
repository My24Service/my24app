import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24_flutter_core/models/models.dart';

class MobileApi with ApiMixin {
  // default and settable for tests
  http.Client _httpClient = new http.Client();

  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Future<bool> doAssign(List<int?> engineerPks, String? orderId) async {
    SlidingToken? newToken = await refreshSlidingToken(_httpClient);

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(getHeaders(newToken.token));

    final Map body = {
      'order_ids': "$orderId",
    };

    int errors = 0;

    for (var i=0; i<engineerPks.length; i++) {
      final int? engineerPk = engineerPks[i];
      final url = await getUrl('/mobile/assign-user/$engineerPk/');

      final response = await _httpClient.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: allHeaders,
      );

      if (response.statusCode != 200) {
        errors++;
      }
    }

    // return
    if (errors == 0) {
      return true;
    }

    return false;
  }

  Future<bool> doAssignMe(String? orderId) async {
    SlidingToken? newToken = await refreshSlidingToken(_httpClient);

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(getHeaders(newToken.token));

    final Map body = {
      'order_ids': "$orderId",
    };

    final url = await getUrl('/mobile/assign-me/');

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode != 200) {
      return true;
    }

    return false;
  }
}

MobileApi mobileApi = MobileApi();
