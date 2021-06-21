import 'package:my24app/order/models/models.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/member/models/models.dart';

class AssignedUserdata {
  final String fullName;
  final String mobile;

  AssignedUserdata({
    this.fullName,
    this.mobile,
  });

  factory AssignedUserdata.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedUserdata(
        fullName: parsedJson['full_name'],
        mobile:  parsedJson['mobile_encrypted']
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
  final List<AssignedUserdata> assignedUserData;

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
    this.assignedUserData,
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

    Customer customer;
    if (parsedJson['customer'] != null) {
      customer = Customer.fromJson(parsedJson['customer']);
    }

    List<AssignedUserdata> assignedUsers = [];
    var parsedUserData = parsedJson['assigned_userdata'] as List;
    if (parsedUserData != null) {
      assignedUsers = parsedUserData.map((i) => AssignedUserdata.fromJson(i)).toList();
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
      assignedUserData: assignedUsers,
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

class AssignedOrderMaterial {
  final int id;
  final int assignedOrderId;
  final int material;
  final int location;
  final String materialName;
  final String materialIdentifier;
  final double amount;

  AssignedOrderMaterial({
    this.id,
    this.assignedOrderId,
    this.material,
    this.location,
    this.materialName,
    this.materialIdentifier,
    this.amount,
  });

  factory AssignedOrderMaterial.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson['amount'] is String) {
      parsedJson['amount'] = double.parse(parsedJson['amount']);
    }

    if (parsedJson['material_identifier'] == null) {
      parsedJson['material_identifier'] = '';
    }

    if (parsedJson['identifier'] == null) {
      parsedJson['identifier'] = '';
    }

    // in case of workorder
    if (parsedJson['material_name'] == null) {
      parsedJson['material_name'] = parsedJson['name'];
    }

    if (parsedJson['material_identifier'] == '' && parsedJson['identifier'] != '') {
      parsedJson['material_identifier'] = parsedJson['identifier'];
    }

    return AssignedOrderMaterial(
      id: parsedJson['id'],
      assignedOrderId: parsedJson['assigned_order'],
      material: parsedJson['material'],
      location: parsedJson['location'],
      materialName: parsedJson['material_name'],
      materialIdentifier: parsedJson['material_identifier'],
      amount: parsedJson['amount'],
    );
  }
}

class AssignedOrderMaterials {
  final int count;
  final String next;
  final String previous;
  final List<AssignedOrderMaterial> results;

  AssignedOrderMaterials({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory AssignedOrderMaterials.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<AssignedOrderMaterial> results = list.map((i) => AssignedOrderMaterial.fromJson(i)).toList();

    return AssignedOrderMaterials(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class AssignedOrderActivity  {
  final int id;
  final String activityDate;
  final int assignedOrderId;
  final String workStart;
  final String workEnd;
  final String travelTo;
  final String travelBack;
  final int odoReadingToStart;
  final int odoReadingToEnd;
  final int odoReadingBackStart;
  final int odoReadingBackEnd;
  final int distanceTo;
  final int distanceBack;
  final String extraWork;
  final String extraWorkDescription;
  final String fullName;

  AssignedOrderActivity({
    this.id,
    this.activityDate,
    this.assignedOrderId,
    this.workStart,
    this.workEnd,
    this.travelTo,
    this.travelBack,
    this.odoReadingToStart,
    this.odoReadingToEnd,
    this.odoReadingBackStart,
    this.odoReadingBackEnd,
    this.distanceTo,
    this.distanceBack,
    this.extraWork,
    this.extraWorkDescription,
    this.fullName,
  });

  factory AssignedOrderActivity.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrderActivity(
      id: parsedJson['id'],
      activityDate: parsedJson['activity_date'],
      workStart: parsedJson['work_start'],
      workEnd: parsedJson['work_end'],
      travelTo: parsedJson['travel_to'],
      travelBack: parsedJson['travel_back'],
      odoReadingToStart: parsedJson['odo_reading_to_start'],
      odoReadingToEnd: parsedJson['odo_reading_to_end'],
      odoReadingBackStart: parsedJson['odo_reading_back_start'],
      odoReadingBackEnd: parsedJson['odo_reading_back_end'],
      distanceTo: parsedJson['distance_to'],
      distanceBack: parsedJson['distance_back'],
      extraWork: parsedJson['extra_work'],
      extraWorkDescription: parsedJson['extra_work_description'],
      fullName: parsedJson['full_name'],
    );
  }
}

class AssignedOrderActivities {
  final int count;
  final String next;
  final String previous;
  final List<AssignedOrderActivity> results;

  AssignedOrderActivities({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory AssignedOrderActivities.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<AssignedOrderActivity> results = list.map((i) => AssignedOrderActivity.fromJson(i)).toList();

    return AssignedOrderActivities(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class AssignedOrderDocument {
  final int id;
  final int assignedOrderId;
  final String name;
  final String description;
  final String document;

  AssignedOrderDocument({
    this.id,
    this.assignedOrderId,
    this.name,
    this.description,
    this.document,
  });

  factory AssignedOrderDocument.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrderDocument(
      id: parsedJson['id'],
      assignedOrderId: parsedJson['assigned_order'],
      name: parsedJson['name'],
      description: parsedJson['description'],
      document: parsedJson['document'],
    );
  }
}

class AssignedOrderDocuments {
  final int count;
  final String next;
  final String previous;
  final List<AssignedOrderDocument> results;

  AssignedOrderDocuments({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory AssignedOrderDocuments.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<AssignedOrderDocument> results = list.map((i) => AssignedOrderDocument.fromJson(i)).toList();

    return AssignedOrderDocuments(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class AssignedOrderWorkOrder {
  final int id;
  final int assignedOrderPk;
  final int assignedOrderWorkorderId;
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
      assignedOrderWorkorderId: parsedJson['assigned_order_workorder_id'],
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

class AssignedOrderWorkOrderSign {
  final Order order;
  final MemberPublic member;
  final int userPk;
  final int assignedOrderWorkorderId;
  final int assignedOrderId;
  final List<AssignedOrderActivity> activity;
  final List<AssignedOrderMaterial> materials;
  final AssignedOrderActivityTotals activityTotals;

  AssignedOrderWorkOrderSign({
    this.order,
    this.member,
    this.userPk,
    this.assignedOrderWorkorderId,
    this.assignedOrderId,
    this.activity,
    this.materials,
    this.activityTotals
  });

  factory AssignedOrderWorkOrderSign.fromJson(Map<String, dynamic> parsedJson) {
    var activityList = parsedJson['assigned_order_activity'] as List;
    List<AssignedOrderActivity> activity = activityList.map((i) => AssignedOrderActivity.fromJson(i)).toList();

    var materialList = parsedJson['assigned_order_materials'] as List;
    List<AssignedOrderMaterial> materials = materialList.map((i) => AssignedOrderMaterial.fromJson(i)).toList();

    AssignedOrderActivityTotals activityTotals = AssignedOrderActivityTotals.fromJson(parsedJson['assigned_order_activity_totals']);

    return AssignedOrderWorkOrderSign(
      order: Order.fromJson(parsedJson['order']),
      member: MemberPublic.fromJson(parsedJson['member']),
      userPk: parsedJson['user_pk'],
      assignedOrderWorkorderId: parsedJson['assigned_order_workorder_id'],
      assignedOrderId: parsedJson['assigned_order_id'],
      activityTotals: activityTotals,
      activity: activity,
      materials: materials
    );
  }
}
