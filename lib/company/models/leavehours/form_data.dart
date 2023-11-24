import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/models/base_models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/company/models/leave_type/models.dart';

class UserLeaveHoursFormData extends BaseFormData<UserLeaveHours>  {
  int? id;
  int? leaveType;
  String? leaveTypeName;

  String? description;

  DateTime? startDate;
  String? startDateHours;
  String? startDateMinutes;
  bool? startDateIsWholeDay = true;

  DateTime? endDate;
  String? endDateHours;
  String? endDateMinutes;
  bool? endDateIsWholeDay = true;

  String? totalHours;
  String? totalMinutes;

  LeaveTypes? leaveTypes;

  dynamic getProp(String key) => <String, dynamic>{
    'startDateHours' : startDateHours,
    'startDateMinutes' : startDateMinutes,
    'endDateHours' : endDateHours,
    'endDateMinutes' : endDateMinutes,
    'totalHours' : totalHours,
    'totalMinutes' : totalMinutes,
  }[key];

  dynamic setProp(String key, String value) {
    switch (key) {
      case 'startDateHours': {
        this.startDateHours = value;
      }
      break;

      case 'startDateMinutes': {
        this.startDateMinutes = value;
      }
      break;

      case 'endDateHours': {
        this.endDateHours = value;
      }
      break;

      case 'endDateMinutes': {
        this.endDateMinutes = value;
      }
      break;

      case 'totalHours': {
        this.totalHours = value;
      }
      break;

      case 'totalMinutes': {
        this.totalMinutes = value;
      }
      break;

      default:
        {
          throw Exception("unknown field: $key");
        }
    }
  }

  UserLeaveHoursFormData({
    this.id,
    this.leaveType,
    this.leaveTypeName,
    this.description,
    this.startDate,
    this.startDateHours,
    this.startDateMinutes,
    this.startDateIsWholeDay,
    this.endDate,
    this.endDateHours,
    this.endDateMinutes,
    this.endDateIsWholeDay,
    this.totalHours,
    this.totalMinutes,
    this.leaveTypes,
  });

  factory UserLeaveHoursFormData.createFromModel(LeaveTypes leaveTypes, UserLeaveHours leaveHours) {
    return UserLeaveHoursFormData(
      id: leaveHours.id,
      leaveType: leaveHours.leaveType,
      leaveTypeName: leaveHours.leaveTypeName,
      leaveTypes: leaveTypes,

      startDate: DateFormat('dd/MM/yyyy').parse(leaveHours.startDate!),
      startDateHours: "${leaveHours.startDateHours}",
      startDateMinutes: "${leaveHours.startDateMinutes}",
      startDateIsWholeDay: leaveHours.startDateIsWholeDay,

      endDate: DateFormat('dd/MM/yyyy').parse(leaveHours.endDate!),
      endDateHours: "${leaveHours.endDateHours}",
      endDateMinutes: "${leaveHours.endDateMinutes}",
      endDateIsWholeDay: leaveHours.endDateIsWholeDay,

      totalMinutes: "${leaveHours.totalMinutes}",
      totalHours: "${leaveHours.totalHours}",

      description: leaveHours.description == null ? "" : leaveHours.description!,
    );
  }

  factory UserLeaveHoursFormData.createEmpty(LeaveTypes leaveTypes) {
    DateTime now = DateTime.now();

    return UserLeaveHoursFormData(
      id: null,
      leaveType: leaveTypes.results!.length > 0 ? leaveTypes.results![0].id : null,
      leaveTypeName: leaveTypes.results!.length > 0 ? leaveTypes.results![0].name : null,
      leaveTypes: leaveTypes,

      startDate: DateTime(now.year, now.month, now.day),
      startDateMinutes: null,
      startDateHours: null,
      startDateIsWholeDay: true,

      endDate: DateTime(now.year, now.month, now.day),
      endDateMinutes: null,
      endDateHours: null,
      endDateIsWholeDay: true,

      totalHours: null,
      totalMinutes: null,

      description: null,
    );
  }

  UserLeaveHours toModel() {
    int? startDateHours;
    int? startDateMinutes;
    if (!this.startDateIsWholeDay!) {
      if (!isEmptyString(this.startDateHours)) {
        startDateHours = int.parse(this.startDateHours!);
      }

      if (!isEmptyString(this.startDateMinutes)) {
        startDateMinutes = int.parse(this.startDateMinutes!);
      } else {
        if (!isEmptyString(this.startDateHours!)) {
          startDateMinutes = 0;
        }
      }
    }

    int? endDateHours;
    int? endDateMinutes;
    if (!this.endDateIsWholeDay!) {
      if (!isEmptyString(this.endDateHours)) {
        endDateHours = int.parse(this.endDateHours!);
      }

      if (!isEmptyString(this.endDateMinutes)) {
        endDateMinutes = int.parse(this.endDateMinutes!);
      } else {
        if (!isEmptyString(this.endDateHours)) {
          endDateMinutes = 0;
        }
      }
    }

    int? totalHours;
    int? totalMinutes;
    if (!isEmptyString(this.totalHours)) {
      totalHours = int.parse(this.totalHours!);
    }

    if (!isEmptyString(this.totalMinutes)) {
      totalMinutes = int.parse(this.totalMinutes!);
    } else {
      if (!isEmptyString(this.totalHours)) {
        totalMinutes = 0;
      }
    }

    return UserLeaveHours(
      id: this.id,
      leaveType: this.leaveType,
      startDate: utils.formatDate(this.startDate!),
      startDateHours: startDateHours,
      startDateMinutes: startDateMinutes,
      startDateIsWholeDay: this.startDateIsWholeDay,
      endDate: utils.formatDate(this.endDate!),
      endDateHours: endDateHours,
      endDateMinutes: endDateMinutes,
      endDateIsWholeDay: this.endDateIsWholeDay,
      totalHours: totalHours,
      totalMinutes: totalMinutes,
      description: this.description
    );
  }

  bool isValid() {
    // if (isEmpty(this.descriptionController.text)) {
    //   return false;
    // }

    return true;
  }
}
