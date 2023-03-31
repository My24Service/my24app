import 'dart:convert';

import 'package:my24app/core/api/base_crud.dart';
import '../workorder/models.dart';
import 'models.dart';

class AssignedOrderApi extends BaseCrud<AssignedOrder, AssignedOrders> {
  final String basePath = "/mobile/assignedorder";

  @override
  AssignedOrder fromJsonDetail(Map<String, dynamic> parsedJson) {
    return AssignedOrder.fromJson(parsedJson);
  }

  @override
  AssignedOrders fromJsonList(Map<String, dynamic> parsedJson) {
    return AssignedOrders.fromJson(parsedJson);
  }

  Future<AssignedOrders> fetchAssignedOrders({query='', page=1}) async {
    // refresh last position
    localUtils.storeLastPosition();

    // send device token
    await localUtils.postDeviceToken();

    return super.list(
        filters: { 'query': query, 'page': page },
        basePathAddition: 'list_app/');
  }

  Future<AssignedOrder> fetchAssignedOrder(int assignedorderPk) async {
    return super.detail(assignedorderPk, basePathAddition: 'detail_device/');
  }

  Future<bool> reportStartCode(StartCode startCode, int assignedorderPk) async {
    final Map body = {
      'statuscode_pk': startCode.id,
    };
    String basePathAddition = '$assignedorderPk/report_statuscode/';
    return super.insertCustom(body, basePathAddition);
  }

  Future<bool> reportEndCode(EndCode endCode, int assignedorderPk) async {
    final Map body = {
      'statuscode_pk': endCode.id,
    };
    String basePathAddition = '$assignedorderPk/report_statuscode/';
    return super.insertCustom(body, basePathAddition);
  }

  Future<bool> reportAfterEndCode(AfterEndCode afterEndCode, int assignedorderPk, String extraData) async {
    final Map body = {
      'statuscode_pk': afterEndCode.id,
      'extra_data': extraData
    };
    String basePathAddition = '$assignedorderPk/report_statuscode/';
    return super.insertCustom(body, basePathAddition);
  }

  Future<Map> createExtraOrder(int assignedorderPk) async {
    final Map body = {};
    String basePathAddition = '$assignedorderPk/create_extra_order/';
    // result['new_assigned_order']
    return super.insertCustom(body, basePathAddition, returnTypeBool: false);
  }

  Future<bool> reportNoWorkorderFinished(int assignedorderPk) async {
    final Map body = {};
    String basePathAddition = '$assignedorderPk/no_workorder_finished/';
    return super.insertCustom(body, basePathAddition);
  }

  Future<AssignedOrderWorkOrderSign> fetchAssignedOrderWorkOrderSign(int assignedorderPk) async {
    final String responseBody = await getListlistResponseBody(
        basePathAddition: '$assignedorderPk/get_workorder_sign_details/'
    );
    return AssignedOrderWorkOrderSign.fromJson(json.decode(responseBody));
  }
}
