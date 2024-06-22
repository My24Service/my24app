import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class AssignedOrderWorkOrderApi extends BaseCrud<AssignedOrderWorkOrder, AssignedOrderWorkOrders> {
  final String basePath = "/mobile/assignedorder-workorder";

  @override
  AssignedOrderWorkOrder fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return AssignedOrderWorkOrder.fromJson(parsedJson!);
  }

  @override
  AssignedOrderWorkOrders fromJsonList(Map<String, dynamic>? parsedJson) {
    return AssignedOrderWorkOrders.fromJson(parsedJson!);
  }
}
