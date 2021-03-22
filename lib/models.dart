import 'dart:convert';
import 'utils.dart';


class Token {
  final String access;
  final String refresh;
  Map<String, dynamic> raw;
  bool isValid;
  bool isExpired;

  Token({
    this.access,
    this.refresh,
    this.isValid,
    this.isExpired,
    this.raw,
  });

  Map<String, dynamic> getPayloadAccess() {
    var accessParts = access.split(".");
    return json.decode(ascii.decode(base64.decode(base64.normalize(accessParts[1]))));
  }

  Map<String, dynamic>  getPayloadRefresh() {
    var refreshParts = refresh.split(".");
    return json.decode(ascii.decode(base64.decode(base64.normalize(refreshParts[1]))));
  }

  int getUserPk() {
    var payload = getPayloadAccess();
    return payload['user_id'];
  }

  DateTime getExpAccesss() {
    var payloadAccess = getPayloadAccess();
    if (payloadAccess == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(payloadAccess["exp"]*1000);
  }

  DateTime getExpRefresh() {
    var payloadRefresh = getPayloadRefresh();
    if (payloadRefresh == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(payloadRefresh["exp"]*1000);
  }

  void checkIsTokenValid() {
    var accessParts = access.split(".");
    var refreshParts = refresh.split(".");

    if(accessParts.length !=3 || refreshParts.length != 3) {
      isValid = false;
    } else {
      isValid = true;
    }
  }

  void checkIsTokenExpired() {
    var payloadAccess = getPayloadAccess();
    if (payloadAccess == null) {
      isExpired = true;
      return;
    }

    if(DateTime.fromMillisecondsSinceEpoch(payloadAccess["exp"]*1000).isAfter(DateTime.now())) {
      isExpired = false;
    } else {
      isExpired = true;
    }
  }

  factory Token.fromJson(Map<String, dynamic> parsedJson) {
    return Token(
      access: parsedJson['access'],
      refresh: parsedJson['refresh'],
      raw: parsedJson,
    );
  }
}

class SlidingToken {
  final String token;
  Map<String, dynamic> raw;
  bool isValid;
  bool isExpired;

  SlidingToken({
    this.token,
    this.isValid,
    this.isExpired,
    this.raw,
  });

  Map<String, dynamic> getPayload() {
    var parts = token.split(".");
    return json.decode(ascii.decode(base64.decode(base64.normalize(parts[1]))));
  }

  int getUserPk() {
    var payload = getPayload();
    return payload['user_id'];
  }

  DateTime getExp() {
    var payloadAccess = getPayload();
    if (payloadAccess == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(payloadAccess["exp"]*1000);
  }

  void checkIsTokenValid() {
    var parts = token.split(".");
    isValid = parts.length == 3 ? true : false;
  }

  void checkIsTokenExpired() {
    var payload = getPayload();
    if (payload == null) {
      isExpired = true;
      return;
    }
    print(payload);

    var expires = DateTime.fromMillisecondsSinceEpoch(payload["exp"]*1000);
    print('expires: $expires');

    if(expires.isAfter(DateTime.now())) {
      isExpired = false;
    } else {
      isExpired = true;
    }
  }

  factory SlidingToken.fromJson(Map<String, dynamic> parsedJson) {
    return SlidingToken(
      token: parsedJson['token'],
      raw: parsedJson,
    );
  }
}


class Members {
  final int count;
  final String next;
  final String previous;
  final List<MemberPublic> results;

  Members({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Members.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<MemberPublic> results = list.map((i) => MemberPublic.fromJson(i)).toList();

    return Members(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

class MemberPublic {
  final int pk;
  final String companycode;
  final String companylogo;
  final String companylogoUrl;
  final String name;
  final String address;
  final String postal;
  final String city;
  final String countryCode;
  final String tel;
  final String email;

  MemberPublic({
    this.pk,
    this.companycode,
    this.companylogo,
    this.companylogoUrl,
    this.name,
    this.address,
    this.postal,
    this.city,
    this.countryCode,
    this.tel,
    this.email,
  });

  factory MemberPublic.fromJson(Map<String, dynamic> parsedJson) {

    return MemberPublic(
      pk: parsedJson['id'],
      companycode: parsedJson['companycode'],
      companylogo: parsedJson['companylogo'],
      companylogoUrl: parsedJson['companylogo_url'],
      name: parsedJson['name'],
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      tel: parsedJson['tel'],
      email: parsedJson['email'],
    );
  }
}

class EngineerProperty {
  final String address;
  final String postal;
  final String city;
  final String countryCode;
  final String mobile;

  EngineerProperty({
    this.address,
    this.postal,
    this.city,
    this.countryCode,
    this.mobile,
  });

  factory EngineerProperty.fromJson(Map<String, dynamic> parsedJson) {
    return EngineerProperty(
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      mobile: parsedJson['mobile'],
    );
  }
}

class EngineerUser {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;
  EngineerProperty engineer;

  EngineerUser({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
    this.engineer,
  });

  factory EngineerUser.fromJson(Map<String, dynamic> parsedJson) {
    return EngineerUser(
      id: parsedJson['id'],
      email: parsedJson['email'],
      username: parsedJson['username'],
      fullName: parsedJson['fullName'],
      firstName: parsedJson['first_name'],
      lastName: parsedJson['last_name'],
      engineer: EngineerProperty.fromJson(parsedJson['engineer']),
    );
  }
}

class CustomerProperty {
  final int customer;

  CustomerProperty({
    this.customer,
  });

  factory CustomerProperty.fromJson(Map<String, dynamic> parsedJson) {
    return CustomerProperty(
      customer: parsedJson['customer'],
    );
  }
}

class CustomerUser {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;
  final CustomerProperty customer;
  final Customer customerDetails;

  CustomerUser({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
    this.customer,
    this.customerDetails,
  });

  factory CustomerUser.fromJson(Map<String, dynamic> parsedJson) {
    return CustomerUser(
      id: parsedJson['id'],
      email: parsedJson['email'],
      username: parsedJson['username'],
      fullName: parsedJson['fullName'],
      firstName: parsedJson['first_name'],
      lastName: parsedJson['last_name'],
      customer: CustomerProperty.fromJson(parsedJson['customer_user']),
      customerDetails: Customer.fromJson(parsedJson['customer_details'])
    );
  }
}

class PlanningUser {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;

  PlanningUser({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
  });

  factory PlanningUser.fromJson(Map<String, dynamic> parsedJson) {
    return PlanningUser(
        id: parsedJson['id'],
        email: parsedJson['email'],
        username: parsedJson['username'],
        fullName: parsedJson['fullName'],
        firstName: parsedJson['first_name'],
        lastName: parsedJson['last_name'],
    );
  }
}

class SalesUser {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;

  SalesUser({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
  });

  factory SalesUser.fromJson(Map<String, dynamic> parsedJson) {
    return SalesUser(
      id: parsedJson['id'],
      email: parsedJson['email'],
      username: parsedJson['username'],
      fullName: parsedJson['fullName'],
      firstName: parsedJson['first_name'],
      lastName: parsedJson['last_name'],
    );
  }
}

class SalesUserCustomer {
  final int id;
  final int salesUser;
  final Customer customerDetails;

  SalesUserCustomer({
    this.id,
    this.salesUser,
    this.customerDetails,
  });

  factory SalesUserCustomer.fromJson(Map<String, dynamic> parsedJson) {
    return SalesUserCustomer(
      id: parsedJson['id'],
      salesUser: parsedJson['sales_user'],
      customerDetails: Customer.fromJson(parsedJson['customer_details'])
    );
  }
}

class SalesUserCustomers {
  final int count;
  final String next;
  final String previous;
  final List<SalesUserCustomer> results;

  SalesUserCustomers({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory SalesUserCustomers.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<SalesUserCustomer> results = list.map((i) => SalesUserCustomer.fromJson(i)).toList();

    return SalesUserCustomers(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

class Orderline {
  final String product;
  final String location;
  final String remarks;

  Orderline({
    this.product,
    this.location,
    this.remarks,
  });

  factory Orderline.fromJson(Map<String, dynamic> parsedJson) {
    return Orderline(
      product: parsedJson['product'],
      location: parsedJson['location'],
      remarks: parsedJson['remarks'],
    );
  }
}

class Infoline {
  final String info;

  Infoline({
    this.info,
  });

  factory Infoline.fromJson(Map<String, dynamic> parsedJson) {
    return Infoline(
      info: parsedJson['info'],
    );
  }
}

class Status {
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
}

class OrderDocument {
  final int id;
  final int orderId;
  final String name;
  final String description;
  final String file;
  final String url;

  OrderDocument({
    this.id,
    this.orderId,
    this.name,
    this.description,
    this.file,
    this.url,
  });

  factory OrderDocument.fromJson(Map<String, dynamic> parsedJson) {
    return OrderDocument(
      id: parsedJson['id'],
      orderId: parsedJson['order'],
      name: parsedJson['name'],
      description: parsedJson['description'],
      file: parsedJson['file'],
      url: parsedJson['url'],
    );
  }
}

class OrderDocuments {
  final int count;
  final String next;
  final String previous;
  final List<OrderDocument> results;

  OrderDocuments({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory OrderDocuments.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<OrderDocument> results = list.map((i) => OrderDocument.fromJson(i)).toList();

    return OrderDocuments(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

class Order {
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
  final String lastStatus;
  final String orderName;
  final String orderAddress;
  final String orderPostal;
  final String orderCity;
  final String orderCountryCode;
  final String orderTel;
  final String orderMobile;
  final String orderEmail;
  final String orderContact;
  final String lastStatusFull;
  final int requireUsers;
  final String created;
  final String totalPricePurchase;
  final String totalPriceSelling;
  final String workorderPdfUrl;
  final bool customerOrderAccepted;
  final List<Orderline> orderLines;
  final List<Infoline> infoLines;
  final List<Status> statusses;
  final List<OrderDocument> documents;

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
    this.lastStatus,
    this.orderName,
    this.orderAddress,
    this.orderPostal,
    this.orderCity,
    this.orderCountryCode,
    this.orderTel,
    this.orderMobile,
    this.orderContact,
    this.lastStatusFull,
    this.requireUsers,
    this.created,
    this.totalPricePurchase,
    this.totalPriceSelling,
    this.orderDate,
    this.orderEmail,
    this.workorderPdfUrl,
    this.customerOrderAccepted,
    this.orderLines,
    this.infoLines,
    this.statusses,
    this.documents,
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

    // statusses
    List<Status> statusses = [];
    var parsedStatusses = parsedJson['statusses'] as List;

    if (parsedStatusses != null) {
      statusses = parsedStatusses.map((i) => Status.fromJson(i)).toList();
    }

    // documents
    List<OrderDocument> documents = [];
    var parsedDocuments = parsedJson['documents'] as List;

    if (parsedDocuments != null) {
      documents = parsedDocuments.map((i) => OrderDocument.fromJson(i)).toList();
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
      lastStatus: parsedJson['last_status'],
      orderName: parsedJson['order_name'],
      orderAddress: parsedJson['order_address'],
      orderPostal: parsedJson['order_postal'],
      orderCity: parsedJson['order_city'],
      orderCountryCode: parsedJson['order_country_code'],
      orderTel: parsedJson['order_tel'],
      orderMobile: parsedJson['order_mobile'],
      orderContact: parsedJson['order_contact'],
      lastStatusFull: parsedJson['last_status_full'],
      requireUsers: parsedJson['required_users'],
      created: parsedJson['created'],
      totalPricePurchase: parsedJson['total_price_purchase'],
      totalPriceSelling: parsedJson['total_price_selling'],
      orderEmail: parsedJson['order_email'],
      orderDate: parsedJson['order_date'],
      workorderPdfUrl: parsedJson['workorder_pdf_url'],
      customerOrderAccepted: parsedJson['customer_order_accepted'],
      orderLines: orderlines,
      infoLines: infolines,
      statusses: statusses,
      documents: documents,
    );
  }
}

class Orders {
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

class Customer {
  final int id;
  final String name;
  final String address;
  final String postal;
  final String city;
  final String countryCode;
  final String tel;
  final String email;
  final String contact;
  final String mobile;
  final String customerId;
  final String maintenanceContract;
  final String standardHours;

  Customer({
    this.id,
    this.name,
    this.address,
    this.postal,
    this.city,
    this.countryCode,
    this.tel,
    this.email,
    this.contact,
    this.mobile,
    this.customerId,
    this.maintenanceContract,
    this.standardHours
  });

  factory Customer.fromJson(Map<String, dynamic> parsedJson) {
    return Customer(
      id: parsedJson['id'],
      name: parsedJson['name'],
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      tel: parsedJson['tel'],
      email: parsedJson['email'],
      contact: parsedJson['contact'],
      mobile: parsedJson['mobile'],
      customerId: parsedJson['customer_id'],
      maintenanceContract: parsedJson['maintenance_contract'] != null ? parsedJson['maintenance_contract'] : '',
      standardHours: parsedJson['standard_hours_txt'],
    );
  }
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

class AssignedOrderProduct {
  final int id;
  final int assignedOrderId;
  final int productInventory;
  final int locationInventory;
  final String productName;
  final String productIdentifier;
  final double amount;

  AssignedOrderProduct({
    this.id,
    this.assignedOrderId,
    this.productInventory,
    this.locationInventory,
    this.productName,
    this.productIdentifier,
    this.amount,
  });

  factory AssignedOrderProduct.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson['amount'] is String) {
      parsedJson['amount'] = double.parse(parsedJson['amount']);
    }

    if (parsedJson['product_identifier'] == null) {
      parsedJson['product_identifier'] = '';
    }

    if (parsedJson['identifier'] == null) {
      parsedJson['identifier'] = '';
    }

    // in case of workorder
    if (parsedJson['product_name'] == null) {
      parsedJson['product_name'] = parsedJson['name'];
    }

    if (parsedJson['product_identifier'] == '' && parsedJson['identifier'] != '') {
      parsedJson['product_identifier'] = parsedJson['identifier'];
    }

    return AssignedOrderProduct(
        id: parsedJson['id'],
        assignedOrderId: parsedJson['assigned_order'],
        productInventory: parsedJson['product_inventory'],
        locationInventory: parsedJson['location_inventory'],
        productName: parsedJson['product_name'],
        productIdentifier: parsedJson['product_identifier'],
        amount: parsedJson['amount'],
    );
  }
}

class AssignedOrderProducts {
  final int count;
  final String next;
  final String previous;
  final List<AssignedOrderProduct> results;

  AssignedOrderProducts({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory AssignedOrderProducts.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<AssignedOrderProduct> results = list.map((i) => AssignedOrderProduct.fromJson(i)).toList();

    return AssignedOrderProducts(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results,
    );
  }
}

class PurchaseProduct {
  final int id;
  final String productName;
  final String productIdentifier;
  final String value;

  PurchaseProduct({
    this.id,
    this.productName,
    this.productIdentifier,
    this.value,
  });

  factory PurchaseProduct.fromJson(Map<String, dynamic> parsedJson) {
    return PurchaseProduct(
      id: parsedJson['id'],
      productName: parsedJson['name'],
      productIdentifier: parsedJson['identifier'],
      value: parsedJson['value'],
    );
  }
}

class AssignedOrderActivity  {
  final int id;
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
  final String fullName;

  AssignedOrderActivity({
    this.id,
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
    this.fullName,
  });

  factory AssignedOrderActivity.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrderActivity(
      id: parsedJson['id'],
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

class Quotation {
  final int id;
  final String customerId;
  final int customerRelation;
  final String quotationName;
  final String quotationAddress;
  final String quotationPostal;
  final String quotationPoBox;
  final String quotationCity;
  final String quotationCountryCode;
  final String quotationEmail;
  final String quotationTel;
  final String quotationMobile;
  final String quotationContact;
  final String quotationReference;
  final String description;
  final String workHours;
  final String travelTo;
  final String travelBack;
  final int distanceTo;
  final int distanceBack;
  final String signatureEngineer;
  final String signatureNameEngineer;
  final String signatureCustomer;
  final String signatureNameCustomer;
  final String status;
  List<QuotationProduct> quotationProducts;

  Quotation({
    this.id,
    this.customerId,
    this.customerRelation,
    this.quotationName,
    this.quotationAddress,
    this.quotationPostal,
    this.quotationPoBox,
    this.quotationCity,
    this.quotationCountryCode,
    this.quotationEmail,
    this.quotationTel,
    this.quotationMobile,
    this.quotationContact,
    this.quotationReference,
    this.description,
    this.workHours,
    this.travelTo,
    this.travelBack,
    this.distanceTo,
    this.distanceBack,
    this.signatureEngineer,
    this.signatureNameEngineer,
    this.signatureCustomer,
    this.signatureNameCustomer,
    this.status,
    this.quotationProducts,
  });

  factory Quotation.fromJson(Map<String, dynamic> parsedJson) {
    return Quotation(
      id: parsedJson['id'],
      customerId: parsedJson['customer_id'],
      customerRelation: parsedJson['customer_relation'],
      quotationName: parsedJson['quotation_name'],
      quotationAddress: parsedJson['quotation_address'],
      quotationPostal: parsedJson['quotation_postal'],
      quotationPoBox: parsedJson['quotation_po_box'],
      quotationCity: parsedJson['quotation_city'],
      quotationCountryCode: parsedJson['quotation_country_code'],
      quotationEmail: parsedJson['quotation_email'],
      quotationTel: parsedJson['quotation_tel'],
      quotationMobile: parsedJson['quotation_mobile'],
      quotationContact: parsedJson['quotation_contact'],
      quotationReference: parsedJson['quotation_reference'],
      description: parsedJson['description'],
      workHours: parsedJson['work_hours'],
      travelTo: parsedJson['travel_to'],
      travelBack: parsedJson['travel_back'],
      distanceTo: parsedJson['distance_to'],
      distanceBack: parsedJson['distance_back'],
      signatureEngineer: parsedJson['signature_engineer'],
      signatureNameEngineer: parsedJson['signature_name_engineer'],
      signatureCustomer: parsedJson['signature_customer'],
      signatureNameCustomer: parsedJson['signature_name_customer'],
      status: parsedJson['status'],
    );
  }
}

class Quotations {
  final int count;
  final String next;
  final String previous;
  final List<Quotation> results;

  Quotations({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Quotations.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Quotation> results = list.map((i) => Quotation.fromJson(i)).toList();

    return Quotations(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class QuotationProduct {
  final int id;
  final int quotationId;
  final int productId;
  final String productName;
  final String productIdentifier;
  final double amount;
  final String location;
  final String value;

  QuotationProduct({
    this.id,
    this.quotationId,
    this.productId,
    this.productName,
    this.productIdentifier,
    this.amount,
    this.location,
    this.value,
  });

  factory QuotationProduct.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationProduct(
      id: parsedJson['id'],
      productName: parsedJson['name'],
      productIdentifier: parsedJson['identifier'],
      value: parsedJson['value'],
    );
  }
}

class QuotationCustomer {
  final int id;
  final String name;
  final String address;
  final String postal;
  final String city;
  final String countryCode;
  final String tel;
  final String mobile;
  final String email;
  final String customerId;
  final String contact;
  final String remarks;
  final String value;

  QuotationCustomer({
    this.id,
    this.name,
    this.address,
    this.postal,
    this.city,
    this.countryCode,
    this.tel,
    this.mobile,
    this.email,
    this.customerId,
    this.contact,
    this.remarks,
    this.value,
  });

  factory QuotationCustomer.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationCustomer(
      id: parsedJson['id'],
      name: parsedJson['name'],
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      tel: parsedJson['tel'],
      mobile: parsedJson['mobile'],
      email: parsedJson['email'],
      customerId: parsedJson['customerId'],
      contact: parsedJson['contact'],
      remarks: parsedJson['remarks'],
      value: parsedJson['value'],
    );
  }
}

class QuotationImage {
  final int id;
  final String image;
  final String description;

  QuotationImage({
    this.id,
    this.image,
    this.description,
  });

  factory QuotationImage.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationImage(
      id: parsedJson['id'],
      image: parsedJson['image'],
      description: parsedJson['description'],
    );
  }
}

class QuotationImages {
  final int count;
  final String next;
  final String previous;
  final List<QuotationImage> results;

  QuotationImages({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory QuotationImages.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<QuotationImage> results = list.map((i) => QuotationImage.fromJson(i)).toList();

    return QuotationImages(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class AssignedOrderWorkOrder {
  final int id;
  final AssignedOrder assignedOrder;
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
    this.assignedOrder,
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
      assignedOrder: parsedJson['assigned_order'],
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
  final List<AssignedOrderProduct> products;
  final AssignedOrderActivityTotals activityTotals;

  AssignedOrderWorkOrderSign({
    this.order,
    this.member,
    this.userPk,
    this.assignedOrderWorkorderId,
    this.assignedOrderId,
    this.activity,
    this.products,
    this.activityTotals
  });

  factory AssignedOrderWorkOrderSign.fromJson(Map<String, dynamic> parsedJson) {
    var activityList = parsedJson['assigned_order_activity'] as List;
    List<AssignedOrderActivity> activity = activityList.map((i) => AssignedOrderActivity.fromJson(i)).toList();

    var productList = parsedJson['assigned_order_products'] as List;
    List<AssignedOrderProduct> products = productList.map((i) => AssignedOrderProduct.fromJson(i)).toList();

    AssignedOrderActivityTotals activityTotals = AssignedOrderActivityTotals.fromJson(parsedJson['assigned_order_activity_totals']);

    return AssignedOrderWorkOrderSign(
      order: Order.fromJson(parsedJson['order']),
      member: MemberPublic.fromJson(parsedJson['member']),
      userPk: parsedJson['user_pk'],
      assignedOrderWorkorderId: parsedJson['assigned_order_workorder_id'],
      assignedOrderId: parsedJson['assigned_order_id'],
      activityTotals: activityTotals,
      activity: activity,
      products:products
    );
  }
}

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

class StockLocation {
  final int id;
  final String identifier;
  final String name;

  StockLocation({
    this.id,
    this.identifier,
    this.name,
  });

  factory StockLocation.fromJson(Map<String, dynamic> parsedJson) {
    return StockLocation(
      id: parsedJson['id'],
      identifier: parsedJson['identifier'],
      name: parsedJson['name'],
    );
  }
}

class StockLocations {
  final int count;
  final String next;
  final String previous;
  final List<StockLocation> results;

  StockLocations({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory StockLocations.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<StockLocation> results = list.map((i) => StockLocation.fromJson(i)).toList();

    return StockLocations(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

