import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/member/models/models.dart';
import 'package:my24app/company/models/models.dart';
import 'activity/models.dart';
import 'material/models.dart';

class OrderAssignPageData {
  final String memberPicture;
  final List<EngineerUser> engineers;

  OrderAssignPageData({
    this.engineers,
    this.memberPicture
  });
}

class StartCode {
  final int id;
  final String statuscode;
  final String description;

  StartCode({
    this.id,
    this.statuscode,
    this.description,
  });

  factory StartCode.fromJson(Map<String, dynamic> parsedJson) {
    return StartCode(
      id: parsedJson['id'],
      statuscode: parsedJson['statuscode'],
      description: parsedJson['description'],
    );
  }
}

class EndCode {
  final int id;
  final String statuscode;
  final String description;

  EndCode({
    this.id,
    this.statuscode,
    this.description,
  });

  factory EndCode.fromJson(Map<String, dynamic> parsedJson) {
    return EndCode(
      id: parsedJson['id'],
      statuscode: parsedJson['statuscode'],
      description: parsedJson['description'],
    );
  }
}

class AfterEndCode {
  final int id;
  final String statuscode;
  final String description;

  AfterEndCode({
    this.id,
    this.statuscode,
    this.description,
  });

  factory AfterEndCode.fromJson(Map<String, dynamic> parsedJson) {
    return AfterEndCode(
      id: parsedJson['id'],
      statuscode: parsedJson['statuscode'],
      description: parsedJson['description'],
    );
  }
}

class AssignedUserdata {
  final String fullName;
  final String mobile;
  final String date;

  AssignedUserdata({
    this.fullName,
    this.mobile,
    this.date,
  });

  factory AssignedUserdata.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedUserdata(
        fullName: parsedJson['full_name'],
        date: parsedJson['date'],
        mobile:  parsedJson['mobile']
    );
  }
}

class AssignedOrderCodeReport {
  final int statuscodeId;
  final String extraData;

  AssignedOrderCodeReport({
    this.statuscodeId,
    this.extraData
  });

  factory AssignedOrderCodeReport.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrderCodeReport(
        statuscodeId: parsedJson['statuscode_id'],
        extraData:  parsedJson['extra_data']
    );
  }
}

class AssignedOrder {
  final int id;
  final int engineer;
  final int studentUser;
  final Order order;
  bool isStarted;
  final bool isEnded;
  final Customer customer;
  final List<StartCode> startCodes;
  final List<EndCode> endCodes;
  final List<AfterEndCode> afterEndCodes;
  final List<AssignedUserdata> assignedUserData;
  final List<AssignedOrderCodeReport> afterEndReports;
  final String assignedorderDate;

  AssignedOrder({
    this.id,
    this.engineer,
    this.studentUser,
    this.order,
    this.isStarted,
    this.isEnded,
    this.customer,
    this.startCodes,
    this.endCodes,
    this.afterEndCodes,
    this.assignedUserData,
    this.afterEndReports,
    this.assignedorderDate,
  });

  factory AssignedOrder.fromJson(Map<String, dynamic> parsedJson) {
    List<StartCode> startCodes = [];
    var parsedStartCodesList = parsedJson['start_codes'] as List;
    if (parsedStartCodesList != null) {
      startCodes = parsedStartCodesList.map((i) => StartCode.fromJson(i)).toList();
    }

    List<EndCode> endCodes = [];
    var parsedEndCodesList = parsedJson['end_codes'] as List;
    if (parsedEndCodesList != null) {
      endCodes = parsedEndCodesList.map((i) => EndCode.fromJson(i)).toList();
    }

    List<AfterEndCode> afterEndCodes = [];
    var parsedAfterEndCodesList = parsedJson['after_end_order_codes'] as List;
    if (parsedAfterEndCodesList != null) {
      afterEndCodes = parsedAfterEndCodesList.map((i) => AfterEndCode.fromJson(i)).toList();
    }

    Customer customer;
    if (parsedJson['customer'] != null) {
      customer = Customer.fromJson(parsedJson['customer']);
    }

    List<AssignedUserdata> assignedUsers = [];
    var parsedUserData = parsedJson['assigned_userdata'] as List;
    if (parsedUserData != null) {
      assignedUsers = parsedUserData.map((i) => AssignedUserdata.fromJson(i)).toList();
    }

    List<AssignedOrderCodeReport> afterEndReports = [];
    var afterEndReportsParsed = parsedJson['after_end_reports'] as List;
    if (afterEndReportsParsed != null) {
      afterEndReports = afterEndReportsParsed.map((i) => AssignedOrderCodeReport.fromJson(i)).toList();
    }

    return AssignedOrder(
      id: parsedJson['id'],
      order: Order.fromJson(parsedJson['order']),
      engineer: parsedJson['engineer'],
      studentUser: parsedJson['student_user'],
      isStarted: parsedJson['is_started'],
      isEnded: parsedJson['is_ended'],
      customer: customer,
      startCodes: startCodes,
      endCodes: endCodes,
      afterEndCodes: afterEndCodes,
      assignedUserData: assignedUsers,
      afterEndReports: afterEndReports,
      assignedorderDate: parsedJson['assignedorder_date'],
    );
  }
}

class AssignedOrders {
  final int count;
  final String next;
  final String previous;
  final List<AssignedOrder> results;

  AssignedOrders({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory AssignedOrders.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<AssignedOrder> results = list.map((i) => AssignedOrder.fromJson(i)).toList();

    return AssignedOrders(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

class AssignedOrderWorkOrder {
  final int id;
  final int assignedOrderPk;
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
    this.assignedOrderPk,
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
      assignedOrderPk: parsedJson['assigned_order'],
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
}

class AssignedOrderActivityTotals {
  final String workTotal;
  final String travelToTotal;
  final String travelBackTotal;
  final int distanceToTotal;
  final int distanceBackTotal;

  AssignedOrderActivityTotals({
    this.workTotal,
    this.travelToTotal,
    this.travelBackTotal,
    this.distanceToTotal,
    this.distanceBackTotal,
  });

  factory AssignedOrderActivityTotals.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrderActivityTotals(
      workTotal: parsedJson['work_total'],
      travelToTotal: parsedJson['travel_to_total'],
      travelBackTotal: parsedJson['travel_back_total'],
      distanceToTotal: parsedJson['distance_to_total'],
      distanceBackTotal: parsedJson['distance_back_total'],
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
