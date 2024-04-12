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
}
