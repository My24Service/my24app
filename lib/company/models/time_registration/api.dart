import 'package:my24app/core/api/base_crud.dart';
import 'models.dart';

class TimeRegistrationApi extends BaseCrud<TimeRegistrationDummy, TimeRegistration> {
  final String basePath = "/company/time-registration";

  @override
  TimeRegistrationDummy fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return TimeRegistrationDummy.fromJson(parsedJson!);
  }

  @override
  TimeRegistration fromJsonList(Map<String, dynamic>? parsedJson) {
    return TimeRegistration.fromJson(parsedJson!);
  }
}
