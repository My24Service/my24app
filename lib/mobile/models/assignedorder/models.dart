import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_orders/models/order/models.dart';

import 'package:my24app/customer/models/models.dart';

class AssignedOrder extends BaseModel {
  final int? id;
  final int? engineer;
  final int? studentUser;
  final Order? order;
  bool? isStarted;
  final bool? isEnded;
  final Customer? customer;
  final List<StartCode>? startCodes;
  final List<EndCode>? endCodes;
  final List<AfterEndCode>? afterEndCodes;
  final List<AssignedUserdata>? assignedUserData;
  final List<AssignedOrderCodeReport>? afterEndReports;
  final String? assignedorderDate;

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
    var parsedStartCodesList = parsedJson['start_codes'] as List?;
    if (parsedStartCodesList != null) {
      startCodes = parsedStartCodesList.map((i) => StartCode.fromJson(i)).toList();
    }

    List<EndCode> endCodes = [];
    var parsedEndCodesList = parsedJson['end_codes'] as List?;
    if (parsedEndCodesList != null) {
      endCodes = parsedEndCodesList.map((i) => EndCode.fromJson(i)).toList();
    }

    List<AfterEndCode> afterEndCodes = [];
    var parsedAfterEndCodesList = parsedJson['after_end_order_codes'] as List?;
    if (parsedAfterEndCodesList != null) {
      afterEndCodes = parsedAfterEndCodesList.map((i) => AfterEndCode.fromJson(i)).toList();
    }

    Customer? customer;
    if (parsedJson['customer'] != null) {
      customer = Customer.fromJson(parsedJson['customer']);
    }

    List<AssignedUserdata> assignedUsers = [];
    var parsedUserData = parsedJson['assigned_userdata'] as List?;
    if (parsedUserData != null) {
      assignedUsers = parsedUserData.map((i) => AssignedUserdata.fromJson(i)).toList();
    }

    List<AssignedOrderCodeReport> afterEndReports = [];
    var afterEndReportsParsed = parsedJson['after_end_reports'] as List?;
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

  @override
  String toJson() {
    return '';
  }
}

class AssignedOrders extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<AssignedOrder>? results;

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

class StartCode {
  final int? id;
  final String? statuscode;
  final String? description;

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
  final int? id;
  final String? statuscode;
  final String? description;

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
  final int? id;
  final String? statuscode;
  final String? description;

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
  final String? fullName;
  final String? mobile;
  final String? date;

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
  final int? statuscodeId;
  final String? extraData;

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
