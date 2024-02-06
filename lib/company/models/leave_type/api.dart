import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class LeaveTypeApi extends BaseCrud<LeaveType, LeaveTypes> {
  final String basePath = "/company/leave-type";

  @override
  LeaveType fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return LeaveType.fromJson(parsedJson!);
  }

  @override
  LeaveTypes fromJsonList(Map<String, dynamic>? parsedJson) {
    return LeaveTypes.fromJson(parsedJson!);
  }

  Future<LeaveTypes> fetchLeaveTypesForSelect() async {
    return super.list(
        basePathAddition: 'list_for_select/');
  }
}
