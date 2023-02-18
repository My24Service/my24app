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

  bool isEmpty(String val) {
    return val == '0' || val == '00' || val == null || val == '';
  }

  String hourMinToTimestring(String hours, String minutes) {
    if (this.isEmpty(hours)) {
      hours = "00";
    }

    if (this.isEmpty(minutes)) {
      minutes = "00";
    }

    return '$hours:$minutes:00';
  }
}

abstract class BaseModel {
  BaseModel();
  String toJson();
  factory BaseModel.fromJson(Map<String, dynamic> parsedJson) {
    throw UnimplementedError();
  }
}

abstract class BaseModelPagination {
  BaseModelPagination();
  factory BaseModelPagination.fromJson(Map<String, dynamic> parsedJson) {
    print("BaseModelPagination.fromJson not implemented");
    throw UnimplementedError();
  }
}

DateTime getDateTimeFromString(String dateIn) {
  return DateFormat('d/M/yyyy').parse(dateIn);
}
