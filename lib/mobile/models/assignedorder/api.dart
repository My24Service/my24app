import 'dart:async';
import 'dart:convert';

import 'package:my24app/core/api/base_crud.dart';
import '../workorder/models.dart';
import 'models.dart';

class AssignedOrderApi extends BaseCrud<AssignedOrder, AssignedOrders> {
  final String basePath = "/mobile/assignedorder";

  @override
  AssignedOrder fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return AssignedOrder.fromJson(parsedJson!);
  }

  @override
  AssignedOrders fromJsonList(Map<String, dynamic>? parsedJson) {
    return AssignedOrders.fromJson(parsedJson!);
  }

  Future<AssignedOrders> fetchAssignedOrders({query='', page=1}) async {
    // refresh last position
    storeLastPosition(httpClient);

    // send device token
    await postDeviceToken(httpClient);

    return super.list(
        filters: { 'q': query, 'page': page },
        basePathAddition: 'list_app/');
  }

  Future<AssignedOrder> fetchAssignedOrder(int assignedOrderId) async {
    return await super.detail(assignedOrderId, basePathAddition: 'detail_device/');
  }

  Future<bool> reportStartCode(StartCode startCode, int assignedOrderId) async {
    final Map body = {
      'statuscode_pk': startCode.id,
    };
    String basePathAddition = '$assignedOrderId/report_statuscode/';
    return await super.insertCustom(body, basePathAddition);
  }

  Future<bool> reportEndCode(EndCode endCode, int assignedOrderId) async {
    final Map body = {
      'statuscode_pk': endCode.id,
    };
    String basePathAddition = '$assignedOrderId/report_statuscode/';
    return await super.insertCustom(body, basePathAddition);
  }

  Future<bool> reportAfterEndCode(AfterEndCode afterEndCode, int assignedOrderId, String? extraData) async {
    final Map body = {
      'statuscode_pk': afterEndCode.id,
      'extra_data': extraData
    };
    String basePathAddition = '$assignedOrderId/report_statuscode/';
    return await super.insertCustom(body, basePathAddition);
  }

  Future<dynamic> createExtraOrder(int assignedOrderId) async {
    final Map body = {};
    String basePathAddition = '$assignedOrderId/create_extra_order/';
    // result['new_assigned_order']
    return super.insertCustom(body, basePathAddition, returnTypeBool: false);
  }

  Future<bool> reportNoWorkorderFinished(int assignedOrderId) async {
    final Map body = {};
    String basePathAddition = '$assignedOrderId/no_workorder_finished/';
    return await super.insertCustom(body, basePathAddition);
  }

  Future<AssignedOrderWorkOrderSign> fetchWorkOrderSign(int assignedOrderId) async {
    final String responseBody = await getListResponseBody(
        basePathAddition: '$assignedOrderId/get_workorder_sign_details/'
    );
    return AssignedOrderWorkOrderSign.fromJson(json.decode(responseBody));
  }
}
