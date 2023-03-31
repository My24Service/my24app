import 'dart:convert';

import 'package:my24app/core/models/base_models.dart';

import 'package:my24app/member/models/models.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/mobile/models/activity/models.dart';
import 'package:my24app/mobile/models/material/models.dart';

class AssignedOrderWorkOrder extends BaseModel {
  final int id;
  final int assignedOrderId;
  final String assignedOrderWorkorderId;
  final String descriptionWork;
  final String equipment;
  final String signatureUser;  // base64 encoded image
  final String signatureNameUser;
  final String signatureCustomer;  // base64 encoded image
  final String signatureNameCustomer;
  final String customerEmails;

  AssignedOrderWorkOrder({
    this.id,
    this.assignedOrderId,
    this.assignedOrderWorkorderId,
    this.descriptionWork,
    this.equipment,
    this.signatureUser,
    this.signatureNameUser,
    this.signatureCustomer,
    this.signatureNameCustomer,
    this.customerEmails
  });

  factory AssignedOrderWorkOrder.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrderWorkOrder(
      id: parsedJson['id'],
      assignedOrderId: parsedJson['assigned_order'],
      assignedOrderWorkorderId: "${parsedJson['assigned_order_workorder_id']}",
      descriptionWork: parsedJson['description_work'],
      equipment: parsedJson['equipment'],
      signatureUser: parsedJson['signature_user'],
      signatureNameUser: parsedJson['signature_name_user'],
      signatureCustomer: parsedJson['signature_customer'],
      signatureNameCustomer: parsedJson['signature_name_customer'],
      customerEmails: parsedJson['customer_emails'],
    );
  }

  @override
  String toJson() {
    final Map body = {
      'assigned_order': assignedOrderId,
      'signature_name_user': signatureNameUser,
      'signature_name_customer': signatureNameCustomer,
      'signature_user': signatureUser,
      'signature_customer': signatureCustomer,
      'description_work': descriptionWork,
      'equipment': equipment,
      'customer_emails': customerEmails,
    };

    return json.encode(body);
  }
}

class AssignedOrderWorkOrders extends BaseModelPagination {
  final int count;
  final String next;
  final String previous;
  final List<AssignedOrderWorkOrder> results;

  AssignedOrderWorkOrders({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory AssignedOrderWorkOrders.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<AssignedOrderWorkOrder> results = list.map((i) => AssignedOrderWorkOrder.fromJson(i)).toList();

    return AssignedOrderWorkOrders(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

class AssignedOrderWorkOrderSign {
  final Order order;
  final MemberPublic member;
  final int userPk;
  final String assignedOrderWorkorderId;
  final int assignedOrderId;
  final List<AssignedOrderActivity> activity;
  final List<AssignedOrderExtraWork> extraWork;
  final List<AssignedOrderMaterial> materials;
  final AssignedOrderActivityTotals activityTotals;
  final AssignedOrderExtraWorkTotals extraWorkTotals;

  AssignedOrderWorkOrderSign({
    this.order,
    this.member,
    this.userPk,
    this.assignedOrderWorkorderId,
    this.assignedOrderId,
    this.activity,
    this.extraWork,
    this.materials,
    this.activityTotals,
    this.extraWorkTotals,
  });

  factory AssignedOrderWorkOrderSign.fromJson(Map<String, dynamic> parsedJson) {
    var activityList = parsedJson['assigned_order_activity'] as List;
    List<AssignedOrderActivity> activity = activityList.map((i) => AssignedOrderActivity.fromJson(i)).toList();

    var extraWorkList = parsedJson['assigned_order_extra_work'] as List;
    List<AssignedOrderExtraWork> extraWork = extraWorkList.map((i) => AssignedOrderExtraWork.fromJson(i)).toList();

    var materialList = parsedJson['assigned_order_materials'] as List;
    List<AssignedOrderMaterial> materials = materialList.map((i) => AssignedOrderMaterial.fromJson(i)).toList();

    AssignedOrderActivityTotals activityTotals = AssignedOrderActivityTotals.fromJson(parsedJson['assigned_order_activity_totals']);
    AssignedOrderExtraWorkTotals extraWorkTotals = AssignedOrderExtraWorkTotals.fromJson(parsedJson['assigned_order_extra_work_totals']);

    return AssignedOrderWorkOrderSign(
      order: Order.fromJson(parsedJson['order']),
      member: MemberPublic.fromJson(parsedJson['member']),
      userPk: parsedJson['user_pk'],
      assignedOrderWorkorderId: "${parsedJson['assigned_order_workorder_id']}",
      assignedOrderId: parsedJson['assigned_order_id'],
      activityTotals: activityTotals,
      activity: activity,
      extraWork: extraWork,
      materials: materials,
      extraWorkTotals: extraWorkTotals,
    );
  }
}

class AssignedOrderExtraWork {
  final String extraWork;
  final String extraWorkDescription;

  AssignedOrderExtraWork({
    this.extraWork,
    this.extraWorkDescription,
  });

  factory AssignedOrderExtraWork.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrderExtraWork(
      extraWork: parsedJson['extra_work'],
      extraWorkDescription: parsedJson['extra_work_description'],
    );
  }
}

class AssignedOrderExtraWorkTotals {
  final String extraWork;

  AssignedOrderExtraWorkTotals({
    this.extraWork,
  });

  factory AssignedOrderExtraWorkTotals.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrderExtraWorkTotals(
      extraWork: parsedJson['extra_work'],
    );
  }
}
