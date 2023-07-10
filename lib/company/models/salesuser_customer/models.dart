import 'dart:convert';

import 'package:my24app/core/models/base_models.dart';
import 'package:my24app/customer/models/models.dart';

class SalesUserCustomer extends BaseModel {
  final int? id;
  final int? customer;
  final Customer? customerDetails;

  SalesUserCustomer({
    this.id,
    this.customer,
    this.customerDetails,
  });

  factory SalesUserCustomer.fromJson(Map<String, dynamic> parsedJson) {
    return SalesUserCustomer(
        id: parsedJson['id'],
        customerDetails: Customer.fromJson(parsedJson['customer_details'])
    );
  }

  @override
  String toJson() {
    return json.encode({
      'customer': customer,
    });
  }
}

class SalesUserCustomers extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<SalesUserCustomer>? results;

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
