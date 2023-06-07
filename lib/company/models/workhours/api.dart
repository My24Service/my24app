import 'package:my24app/core/api/base_crud.dart';
import 'models.dart';

class UserWorkHoursApi extends BaseCrud<UserWorkHours, UserWorkHoursPaginated> {
  final String basePath = "/company/user-workhours";

  @override
  UserWorkHours fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return UserWorkHours.fromJson(parsedJson!);
  }

  @override
  UserWorkHoursPaginated fromJsonList(Map<String, dynamic>? parsedJson) {
    return UserWorkHoursPaginated.fromJson(parsedJson!);
  }
}
