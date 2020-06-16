import 'dart:convert';

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

class Order {
  final int id;
  final String customerId;
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

  Order({
    this.id,
    this.customerId,
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
  });

  factory Order.fromJson(Map<String, dynamic> parsedJson) {
    return Order(
      id: parsedJson['id'],
      customerId: 'customer_id',
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
    );
  }
}

class AssignedOrder {
  final int id;
  final int engineer;
  final int studentUser;
  final Order order;
  final String started;
  final String ended;

  AssignedOrder({
    this.id,
    this.engineer,
    this.studentUser,
    this.order,
    this.started,
    this.ended,
  });

  factory AssignedOrder.fromJson(Map<String, dynamic> parsedJson) {
    return AssignedOrder(
      id: parsedJson['id'],
      order: Order.fromJson(parsedJson['order']),
      engineer: parsedJson['engineer'],
      studentUser: parsedJson['student_user'],
      started: parsedJson['started'],
      ended: parsedJson['ended'],
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
