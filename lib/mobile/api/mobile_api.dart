import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/mobile/models/models.dart';

class MobileApi with ApiMixin {
  // default and setable for tests
  http.Client _httpClient = new http.Client();

  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Utils localUtils = utils;

  Future<bool> doAssign(List<int> engineerPks, String orderId) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'order_ids': "$orderId",
    };

    int errors = 0;

    for (var i=0; i<engineerPks.length; i++) {
      final int engineerPk = engineerPks[i];
      final url = await getUrl('/mobile/assign-user-submodel/$engineerPk/');

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

  Future<AssignedOrders> fetchAssignedOrders() async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    // refresh last position
    localUtils.storeLastPosition();

    // send device token
    await localUtils.postDeviceToken();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('user_id');
    final url = await getUrl('/mobile/assignedorder/list_app/?user_pk=$userId');

    final response = await _httpClient.get(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return AssignedOrders.fromJson(json.decode(response.body));
    }

    throw Exception('assigned_orders.list.exception_fetch'.tr());
  }

}

MobileApi mobileApi = MobileApi();
