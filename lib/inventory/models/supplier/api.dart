import 'dart:convert';

import 'package:my24_flutter_core/api/base_crud.dart';

import 'models.dart';

class SupplierApi extends BaseCrud<Supplier, Suppliers> {
  final String basePath = "/inventory/supplier";

  @override
  Supplier fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Supplier.fromJson(parsedJson!);
  }

  @override
  Suppliers fromJsonList(Map<String, dynamic>? parsedJson) {
    return Suppliers.fromJson(parsedJson!);
  }

  Future <List<SupplierTypeAheadModel>> typeAhead(String query) async {
    Map<String, dynamic> filters = {'q': query};
    final String responseBody = await getListResponseBody(
        filters: filters, basePathAddition: 'autocomplete');
    var parsedJson = json.decode(responseBody);
    var list = parsedJson as List;
    List<SupplierTypeAheadModel> results = list.map((i) =>
        SupplierTypeAheadModel.fromJson(i)).toList();

    return results;
  }
}
