import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:my24app/core/models/base_models.dart';
import '../document/models.dart';

class OrderPageMetaData {
  final Widget drawer;
  final String submodel;
  final String firstName;
  final String memberPicture;
  final int pageSize;
  final bool hasBranches;

  OrderPageMetaData({
    this.drawer,
    this.submodel,
    this.firstName,
    this.memberPicture,
    this.pageSize,
    this.hasBranches
  });
}

class Orderline extends BaseModel {
  final String product;
  final String location;
  final String remarks;
  final double pricePurchase;
  final double priceSelling;
  final int materialRelation;
  final int amount;
  final int locationRelationInventory;

  Orderline({
    this.product,
    this.location,
    this.remarks,
    this.pricePurchase,
    this.priceSelling,
    this.materialRelation,
    this.amount,
    this.locationRelationInventory,
  });

  factory Orderline.fromJson(Map<String, dynamic> parsedJson) {
    double pricePurchase = parsedJson['price_purchase'] != null ? double.parse(parsedJson['price_purchase']) : 0;
    double priceSelling = parsedJson['price_selling'] != null ? double.parse(parsedJson['price_selling']) : 0;

    return Orderline(
      product: parsedJson['product'],
      location: parsedJson['location'],
      remarks: parsedJson['remarks'],
      pricePurchase: pricePurchase,
      priceSelling: priceSelling,
      materialRelation: parsedJson['material_relation'],
      locationRelationInventory: parsedJson['location_relation_inventory'],
      amount: parsedJson['amount'],
    );
  }

  @override
  String toJson() {
    Map body = {
      'product': this.product,
      'location': this.location,
      'remarks': this.remarks,
      'material_relation': this.materialRelation,
      'location_relation_inventory': this.locationRelationInventory,
      'amount': this.amount,
    };

    return json.encode(body);
  }
}

class Infoline extends BaseModel {
  final String info;

  Infoline({
    this.info,
  });

  factory Infoline.fromJson(Map<String, dynamic> parsedJson) {
    return Infoline(
      info: parsedJson['info'],
    );
  }

  @override
  String toJson() {
    Map body = {
      'info': this.info,
    };

    return json.encode(body);
  }
}

class Status extends BaseModel {
  final int id;
  final int orderId;
  final String status;
  final String modified;
  final String created;

  Status({
    this.id,
    this.orderId,
    this.status,
    this.modified,
    this.created,
  });

  factory Status.fromJson(Map<String, dynamic> parsedJson) {
    return Status(
      id: parsedJson['id'],
      orderId: parsedJson['order'],
      status: parsedJson['status'],
      modified: parsedJson['modified'],
      created: parsedJson['created'],
    );
  }

  @override
  String toJson() {
    Map body = {
      'id': this.id,
      'order': this.orderId,
      'status': this.status,
    };

    return json.encode(body);
  }
}

class WorkOrderDocument extends BaseModel {
  final String name;
  final String url;

  WorkOrderDocument({
    this.name,
    this.url,
  });

  factory WorkOrderDocument.fromJson(Map<String, dynamic> parsedJson) {
    return WorkOrderDocument(
      name: parsedJson['name'],
      url: parsedJson['url'],
    );
  }

  @override
  String toJson() {
    Map body = {
      'name': this.name,
      'url': this.url,
    };

    return json.encode(body);
  }
}

class OrderAssignedUserInfo extends BaseModel {
  final String fullName;
  final String licensePlate;

  OrderAssignedUserInfo({
    this.fullName,
    this.licensePlate
  });

  factory OrderAssignedUserInfo.fromJson(Map<String, dynamic> parsedJson) {
    return OrderAssignedUserInfo(
        fullName: parsedJson['full_name'],
        licensePlate: parsedJson['license_plate']
    );
  }

  @override
  String toJson() {
    Map body = {
      'full_name': this.fullName,
      'license_plate': this.licensePlate,
    };

    return json.encode(body);
  }
}

class Order extends BaseModel {
  final int id;
  final String customerId;
  final int customerRelation;
  final String orderId;
  final String serviceNumber;
  final String orderReference;
  final String orderType;
  final String customerRemarks;
  final String description;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final String orderDate;
  final String orderName;
  final String orderAddress;
  final String orderPostal;
  final String orderCity;
  final String orderCountryCode;
  final String orderTel;
  final String orderMobile;
  final String orderEmail;
  final String orderContact;
  final String lastStatus;
  final String lastStatusFull;
  final String lastAcceptedStatus;
  final String lastAcceptedStatusFull;
  final int requireUsers;
  final String created;
  final String totalPricePurchase;
  final String totalPriceSelling;
  final String workorderPdfUrl;
  final bool customerOrderAccepted;
  final int branch;
  final List<Orderline> orderLines;
  final List<Infoline> infoLines;
  final List<Status> statuses;
  final List<OrderDocument> documents;
  final List<OrderAssignedUserInfo> assignedUserInfo;
  final List<WorkOrderDocument> workorderDocuments;

  Order({
    this.id,
    this.customerId,
    this.customerRelation,
    this.orderId,
    this.serviceNumber,
    this.orderReference,
    this.orderType,
    this.customerRemarks,
    this.description,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.orderName,
    this.orderAddress,
    this.orderPostal,
    this.orderCity,
    this.orderCountryCode,
    this.orderTel,
    this.orderMobile,
    this.orderContact,
    this.lastStatus,
    this.lastStatusFull,
    this.lastAcceptedStatus,
    this.lastAcceptedStatusFull,
    this.requireUsers,
    this.created,
    this.totalPricePurchase,
    this.totalPriceSelling,
    this.orderDate,
    this.orderEmail,
    this.workorderPdfUrl,
    this.customerOrderAccepted,
    this.branch,
    this.orderLines,
    this.infoLines,
    this.statuses,
    this.documents,
    this.assignedUserInfo,
    this.workorderDocuments,
  });

  factory Order.fromJson(Map<String, dynamic> parsedJson) {
    // order lines
    List<Orderline> orderlines = [];
    var parsedOrderlines = parsedJson['orderlines'] as List;

    if (parsedOrderlines != null) {
      orderlines = parsedOrderlines.map((i) => Orderline.fromJson(i)).toList();
    }

    // info lines
    List<Infoline> infolines = [];
    var parsedInfolines = parsedJson['infolines'] as List;

    if (parsedInfolines != null) {
      infolines = parsedInfolines.map((i) => Infoline.fromJson(i)).toList();
    }

    // statuses
    List<Status> statuses = [];
    var parsedStatuses = parsedJson['statuses'] as List;

    if (parsedStatuses != null) {
      statuses = parsedStatuses.map((i) => Status.fromJson(i)).toList();
    }

    // documents
    List<OrderDocument> documents = [];
    var parsedDocuments = parsedJson['documents'] as List;

    if (parsedDocuments != null) {
      documents = parsedDocuments.map((i) => OrderDocument.fromJson(i)).toList();
    }

    // workorder documents
    List<WorkOrderDocument> workorderDocuments = [];
    var parsedWorkOrderDocuments = parsedJson['workorder_documents'] as List;

    if (parsedWorkOrderDocuments != null) {
      workorderDocuments = parsedWorkOrderDocuments.map((i) => WorkOrderDocument.fromJson(i)).toList();
    }

    // assigned_user_info
    var assignedUserInfo = parsedJson['assigned_user_info'] as List;

    if (assignedUserInfo != null) {
      assignedUserInfo = assignedUserInfo.map((i) => OrderAssignedUserInfo.fromJson(i)).toList();
    }

    return Order(
      id: parsedJson['id'],
      customerId: parsedJson['customer_id'],
      customerRelation: parsedJson['customer_relation'],
      orderId: parsedJson['order_id'],
      serviceNumber: parsedJson['service_number'],
      orderReference: parsedJson['order_reference'],
      orderType: parsedJson['order_type'],
      customerRemarks: parsedJson['customer_remarks'],
      description: parsedJson['description'],
      startDate: parsedJson['start_date'],
      startTime: parsedJson['start_time'],
      endDate: parsedJson['end_date'],
      endTime: parsedJson['end_time'],
      orderName: parsedJson['order_name'],
      orderAddress: parsedJson['order_address'],
      orderPostal: parsedJson['order_postal'],
      orderCity: parsedJson['order_city'],
      orderCountryCode: parsedJson['order_country_code'],
      orderTel: parsedJson['order_tel'],
      orderMobile: parsedJson['order_mobile'],
      orderContact: parsedJson['order_contact'],
      lastStatus: parsedJson['last_status'],
      lastStatusFull: parsedJson['last_status_full'],
      lastAcceptedStatus: parsedJson['last_accepted_status'],
      lastAcceptedStatusFull: parsedJson['last_accepted_status_full'],
      requireUsers: parsedJson['required_users'],
      created: parsedJson['created'],
      totalPricePurchase: parsedJson['total_price_purchase'],
      totalPriceSelling: parsedJson['total_price_selling'],
      orderEmail: parsedJson['order_email'],
      orderDate: parsedJson['order_date'],
      workorderPdfUrl: parsedJson['workorder_pdf_url'],
      customerOrderAccepted: parsedJson['customer_order_accepted'],
      branch: parsedJson['branch'],
      orderLines: orderlines,
      infoLines: infolines,
      statuses: statuses,
      documents: documents,
      assignedUserInfo: assignedUserInfo,
      workorderDocuments: workorderDocuments,
    );
  }

  @override
  String toJson() {
    // order lines
    List<Map> orderlines = [];
    for (int i=0; i<this.orderLines.length; i++) {
      Orderline orderline = this.orderLines[i];

      // sales orders have these extra fields
      if (orderline.locationRelationInventory != null) {
        orderlines.add({
          'product': orderline.product,
          'location': orderline.location,
          'remarks': orderline.remarks,
          'price_purchase': orderline.pricePurchase,
          'price_selling': orderline.priceSelling,
          'material_relation': orderline.materialRelation,
          'location_relation_inventory': orderline.locationRelationInventory,
          'amount': orderline.amount,
        });
      } else {
        orderlines.add({
          'product': orderline.product,
          'location': orderline.location,
          'remarks': orderline.remarks,
        });
      }
    }

    // info lines
    List<Map> infolines = [];
    if (this.infoLines != null) {
      for (int i=0; i<this.infoLines.length; i++) {
        Infoline infoline = this.infoLines[i];

        infolines.add({
          'info': infoline.info,
        });
      }
    }

    final Map body = {
      'branch': this.branch,
      'customer_id': this.customerId,
      'order_name': this.orderName,
      'order_address': this.orderAddress,
      'order_postal': this.orderPostal,
      'order_city': this.orderCity,
      'order_country_code': this.orderCountryCode,
      'customer_relation': this.customerRelation,
      'order_type': this.orderType,
      'order_reference': this.orderReference,
      'order_tel': this.orderTel,
      'order_mobile': this.orderMobile,
      'order_contact': this.orderContact,
      'start_date': this.startDate,
      'start_time': this.startTime,
      'end_date': this.endDate,
      'end_time': this.endTime,
      'customer_remarks': this.customerRemarks,
      'customer_order_accepted': this.customerOrderAccepted,
      'orderlines': orderlines,
      'infolines': infolines,
      'maintenance_product_lines': []
    };

    return json.encode(body);
  }
}

class Orders extends BaseModelPagination {
  final int count;
  final String next;
  final String previous;
  final List<Order> results;

  Orders({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Orders.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Order> results = list.map((i) => Order.fromJson(i)).toList();

    return Orders(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

// TODO rename these classes
class CustomerHistoryOrder {
  final String orderId;
  final String orderDate;
  final String orderType;
  final String orderReference;
  final String workorderPdfUrl;
  final String workorderPdfUrlPartner;
  final List<Orderline> orderLines;

  CustomerHistoryOrder({
    this.orderId,
    this.orderDate,
    this.orderType,
    this.orderReference,
    this.workorderPdfUrl,
    this.workorderPdfUrlPartner,
    this.orderLines,
  });

  factory CustomerHistoryOrder.fromJson(Map<String, dynamic> parsedJson) {
    var orderLinesParsed = parsedJson['orderlines'] as List;
    List<Orderline> orderLines = orderLinesParsed.map((i) => Orderline.fromJson(i)).toList();

    return CustomerHistoryOrder(
        orderId: parsedJson['order_id'],
        orderDate: parsedJson['order_date'],
        orderType: parsedJson['order_type'],
        orderReference: parsedJson['order_reference'],
        workorderPdfUrl: parsedJson['workorder_pdf_url'],
        workorderPdfUrlPartner: parsedJson['workorder_pdf_url_partner'],
        orderLines: orderLines,
    );
  }
}

class CustomerHistory {
  final String customer;
  final List<CustomerHistoryOrder> orderData;

  CustomerHistory({
    this.customer,
    this.orderData,
  });

  factory CustomerHistory.fromJson(Map<String, dynamic> parsedJson) {
    var orderDataParsed = parsedJson['order_data'] as List;
    List<CustomerHistoryOrder> orderData = orderDataParsed.map((i) => CustomerHistoryOrder.fromJson(i)).toList();

    return CustomerHistory(
      customer: parsedJson['customer'],
      orderData: orderData,
    );
  }
}

class OrderTypes {
  List<String> orderTypes;

  OrderTypes({
    this.orderTypes,
  });

  factory OrderTypes.fromJson(List<dynamic> parsedJson) {
    List<String> orderTypes = new List<String>.from(parsedJson);
    return OrderTypes(
      orderTypes: orderTypes
    );
  }
}
