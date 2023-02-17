import 'package:easy_localization/easy_localization.dart';

class HourMin {
  final String hours;
  final String minutes;

  HourMin({
    this.hours,
    this.minutes
  });

  factory HourMin.fromString(String timeIn) {
    List<String> parts = timeIn.split(":");

    return HourMin(
      hours: parts[0],
      minutes: parts[1]
    );
  }
}

abstract class BaseFormData<T> {
  BaseFormData();

  factory BaseFormData.createEmpty() {
    throw UnimplementedError;
  }

  factory BaseFormData.createFromModel(T data) {
    throw UnimplementedError();
  }

  T toModel();

  HourMin getHourMinFromString(String timeIn) {
    return HourMin.fromString(timeIn);
  }

  String hourMinToTimestring(String hours, String minutes) {
    return '$hours:$minutes:00';
  }
}

abstract class BaseModel {
  String toJson();
}

DateTime getDateTimeFromString(String dateIn) {
  return DateFormat('d/M/yyyy').parse(dateIn);
}
