import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class SalesUserCustomerApi extends BaseCrud<SalesUserCustomer, SalesUserCustomers> {
  final String basePath = "/company/salesusercustomer/my";

  @override
  SalesUserCustomer fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return SalesUserCustomer.fromJson(parsedJson!);
  }

  @override
  SalesUserCustomers fromJsonList(Map<String, dynamic>? parsedJson) {
    return SalesUserCustomers.fromJson(parsedJson!);
  }
}
