import 'dart:convert';

import 'package:my24_flutter_core/models/base_models.dart';

class Supplier extends BaseModel {
  final int? id;
  final String? identifier;
  final String? name;
  final String? address;
  final String? postal;
  final String? country_code;
  final String? contact;
  final String? city;
  final String? tel;
  final String? email;
  final String? mobile;
  final String? remarks;

  Supplier({
    this.id,
    this.identifier,
    this.name,
    this.address,
    this.postal,
    this.country_code,
    this.contact,
    this.city,
    this.tel,
    this.email,
    this.mobile,
    this.remarks
  });

  factory Supplier.fromJson(Map<String, dynamic> parsedJson) {
    return Supplier(
      id: parsedJson['id'],
      identifier: parsedJson['identifier'],
      name: parsedJson['name'],
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      country_code: parsedJson['country_code'],
      contact: parsedJson['contact'],
      city: parsedJson['city'],
      tel: parsedJson['tel'],
      email: parsedJson['email'],
      mobile: parsedJson['mobile'],
      remarks: parsedJson['remarks'],
    );
  }

  @override
  String toJson() {
    Map body = {
      'id': this.id,
      'identifier': this.identifier,
      'name': this.name,
      'address': this.address,
      'postal': this.postal,
      'country_code': this.country_code,
      'contact': this.contact,
      'city': this.city,
      'tel': this.tel,
      'email': this.email,
      'mobile': this.mobile,
      'remarks': this.remarks,
    };

    return json.encode(body);
  }

}

class Suppliers extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<Supplier>? results;

  Suppliers({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Suppliers.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Supplier> results = list.map((i) => Supplier.fromJson(i)).toList();

    return Suppliers(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}
