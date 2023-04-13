import 'dart:convert';

import 'package:my24app/core/models/base_models.dart';

class CustomerPageMetaData {
  final String memberPicture;
  final String submodel;

  CustomerPageMetaData({
    this.memberPicture,
    this.submodel,
  }) : super();
}

class CustomerDocument extends BaseModel {
  final int id;
  final int customer;
  final String name;
  final String description;
  final String file;
  final String url;
  final bool userCanView;

  CustomerDocument({
    this.id,
    this.customer,
    this.name,
    this.description,
    this.file,
    this.url,
    this.userCanView,
  });

  factory CustomerDocument.fromJson(Map<String, dynamic> parsedJson) {
    return CustomerDocument(
      id: parsedJson['id'],
      customer: parsedJson['customer'],
      name: parsedJson['name'],
      description: parsedJson['description'],
      file: parsedJson['file'],
      url: parsedJson['url'],
      userCanView: parsedJson['user_can_view'],
    );
  }

  @override
  String toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class Customer extends BaseModel {
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
  final String remarks;
  final List<CustomerDocument> documents;

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
    this.standardHours,
    this.remarks,
    this.documents,
  });

  factory Customer.fromJson(Map<String, dynamic> parsedJson) {
    // documents
    List<CustomerDocument> documents = [];
    var parsedDocuments = parsedJson['documents'] as List;

    if (parsedDocuments != null) {
      documents = parsedDocuments.map((i) => CustomerDocument.fromJson(i)).toList();
    }

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
      remarks: parsedJson['remarks'],
      documents: documents
    );
  }

  @override
  String toJson() {
    final Map body = {
      'customer_id': customerId,
      'name': name,
      'address': address,
      'postal': postal,
      'city': city,
      'country_code': countryCode,
      'tel': tel,
      'mobile': mobile,
      'email': email,
      'contact': contact,
      'remarks': remarks,
    };

    return json.encode(body);
  }
}

class Customers extends BaseModelPagination {
  final int count;
  final String next;
  final String previous;
  final List<Customer> results;

  Customers({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Customers.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Customer> results = list.map((i) => Customer.fromJson(i)).toList();

    return Customers(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

class CustomerTypeAheadModel {
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

  CustomerTypeAheadModel({
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

  factory CustomerTypeAheadModel.fromJson(Map<String, dynamic> parsedJson) {
    return CustomerTypeAheadModel(
      id: parsedJson['id'],
      name: parsedJson['name'],
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      tel: parsedJson['tel'],
      mobile: parsedJson['mobile'],
      email: parsedJson['email'],
      customerId: parsedJson['customer_id'],
      contact: parsedJson['contact'],
      remarks: parsedJson['remarks'],
      value: parsedJson['value'],
    );
  }
}
