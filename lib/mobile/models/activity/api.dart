import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class ActivityApi extends BaseCrud<AssignedOrderActivity, AssignedOrderActivities> {
  final String basePath = "/mobile/assignedorderactivity";

  @override
  AssignedOrderActivity fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return AssignedOrderActivity.fromJson(parsedJson!);
  }

  @override
  AssignedOrderActivities fromJsonList(Map<String, dynamic>? parsedJson) {
    return AssignedOrderActivities.fromJson(parsedJson!);
  }
}
