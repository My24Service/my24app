import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/order/models/models.dart';

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

    final url = await getUrl('/mobile/assignedorder/list_app/');

    final response = await _httpClient.get(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return AssignedOrders.fromJson(json.decode(response.body));
    }

    throw Exception('assigned_orders.list.exception_fetch'.tr());
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

  Future<bool> deleteAssignedOrderDocment(int assignedOrderDocumentPk) async {
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

  // materials
  Future<AssignedOrderMaterials> fetchAssignedOrderMaterials(int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedordermaterial/?assigned_order=$assignedorderPk');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return AssignedOrderMaterials.fromJson(json.decode(response.body));
    }

    throw Exception('assigned_orders.materials.exception_fetch'.tr());
  }

  Future<AssignedOrderMaterial> insertAssignedOrderMaterial(AssignedOrderMaterial material, int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedordermaterial/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'assigned_order': assignedorderPk,
      'material': material.material,
      'location': material.location,
      'material_name': material.materialName,
      'material_identifier': material.materialIdentifier,
      'amount': material.amount,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return AssignedOrderMaterial.fromJson(json.decode(response.body));
    }

    return null;
  }

  Future<bool> deleteAssignedOrderMaterial(int assignedOrderMaterialPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedordermaterial/$assignedOrderMaterialPk/');
    final response = await _httpClient.delete(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    return false;
  }

  // activity
  Future<AssignedOrderActivities> fetchAssignedOrderActivities(int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorderactivity/?assigned_order=$assignedorderPk');
    final response = await _httpClient.get(
      Uri.parse(url),
      headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return AssignedOrderActivities.fromJson(json.decode(response.body));
    }

    throw Exception('assigned_orders.activity.exception_fetch'.tr());
  }

  Future<AssignedOrderActivity> insertAssignedOrderActivity(AssignedOrderActivity activity, int assignedorderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorderactivity/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'assigned_order': assignedorderPk,
      'distance_to': activity.distanceTo,
      'distance_back': activity.distanceBack,
      'travel_to': activity.travelTo,
      'travel_back': activity.travelBack,
      'work_start': activity.workStart,
      'work_end': activity.workEnd,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return AssignedOrderActivity.fromJson(json.decode(response.body));
    }

    return null;
  }

  Future<bool> deleteAssignedOrderActivity(int activityPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/mobile/assignedorderactivity/$activityPk/');
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

  Future<bool> insertAssignedOrderWorkOrder(AssignedOrderWorkOrder workOrder, int assignedorderPk) async {
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
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

}

MobileApi mobileApi = MobileApi();
