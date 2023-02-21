import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/order/models/models.dart';

class MobileApi with ApiMixin {
  // default and settable for tests
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

  Future<bool> doAssignMe(String orderId) async {
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

  Future<AssignedOrders> fetchAssignedOrders({query='', page=1}) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    // refresh last position
    localUtils.storeLastPosition();

    // send device token
    await localUtils.postDeviceToken();

    // build URL
    // int pageSize = await getPageSize();
    String url = await getUrl('/mobile/assignedorder/list_app/');
    // List<String> args = ["page_size=$pageSize"];
    List<String> args = [];

    if (query != null && query != '') {
      args.add('q=$query');
    }

    if (page != null && page != 1 && page != 0) {
      args.add('page=$page');
    }

    if (args.length > 0) {
      url = '$url?' + args.join('&');
    }

    final response = await _httpClient.get(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return AssignedOrders.fromJson(json.decode(response.body));
    }

    final String errorMsg = 'assigned_orders.list.exception_fetch'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<AssignedOrder> fetchAssignedOrder(int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorder/$assignedorderPk/detail_device/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return AssignedOrder.fromJson(json.decode(response.body));
    }

    throw Exception('assigned_orders.detail.exception_fetch'.tr());
  }

  Future<bool> reportStartCode(StartCode startCode, int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorder/$assignedorderPk/report_statuscode/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'statuscode_pk': startCode.id,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> reportEndCode(EndCode endCode, int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorder/$assignedorderPk/report_statuscode/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'statuscode_pk': endCode.id,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> reportAfterEndCode(AfterEndCode afterEndCode, int assignedorderPk, String extraData) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorder/$assignedorderPk/report_statuscode/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'statuscode_pk': afterEndCode.id,
      'extra_data': extraData
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<Map> createExtraOrder(int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorder/$assignedorderPk/create_extra_order/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {};
    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      // result['new_assigned_order']
      return json.decode(response.body);
    }

    return {'result': false};
  }

  Future<bool> reportNoWorkorderFinished(int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorder/$assignedorderPk/no_workorder_finished/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {};

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  // documents
  Future<AssignedOrderDocuments> fetchAssignedOrderDocuments(int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorderdocument/?assigned_order=$assignedorderPk');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return AssignedOrderDocuments.fromJson(json.decode(response.body));
    }

    throw Exception('assigned_orders.documents.exception_fetch'.tr());
  }

  Future<AssignedOrderDocument> insertAssignedOrderDocument(AssignedOrderDocument document, int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorderdocument/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'assigned_order': assignedorderPk,
      'name': document.name,
      'description': document.description,
      'document': document.document,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return AssignedOrderDocument.fromJson(json.decode(response.body));
    }

    // throw Exception('Error inserting document');
    return null;
  }

  Future<bool> deleteAssignedOrderDocument(int assignedOrderDocumentPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorderdocument/$assignedOrderDocumentPk/');
    final response = await _httpClient.delete(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    return false;
  }

  // workorder
  Future<AssignedOrderWorkOrderSign> fetchAssignedOrderWorkOrderSign(int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorder/$assignedorderPk/get_workorder_sign_details/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return AssignedOrderWorkOrderSign.fromJson(json.decode(response.body));
    }

    throw Exception('assigned_orders.workorder.exception_fetch'.tr());
  }

  Future<AssignedOrderWorkOrder> insertAssignedOrderWorkOrder(AssignedOrderWorkOrder workOrder, int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorder-workorder/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'assigned_order': assignedorderPk,
      'signature_name_user': workOrder.signatureNameUser,
      'signature_name_customer': workOrder.signatureNameCustomer,
      'signature_user': workOrder.signatureUser,
      'signature_customer': workOrder.signatureCustomer,
      'description_work': workOrder.descriptionWork,
      'equipment': workOrder.equipment,
      'customer_emails': workOrder.customerEmails,
    };

    final response = await _httpClient.post(
      Uri.parse("$url?no_pdf=1"),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      AssignedOrderWorkOrder workOrder = AssignedOrderWorkOrder.fromJson(json.decode(response.body));
      return workOrder;
    }

    return null;
  }

}

MobileApi mobileApi = MobileApi();
