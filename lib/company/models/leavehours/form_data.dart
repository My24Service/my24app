import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/company/models/leave_type/models.dart';

class UserLeaveHoursFormData extends BaseFormData<UserLeaveHours>  {
  int? id;
  int? leaveType;
  String? leaveTypeName;

  TextEditingController? descriptionController = TextEditingController();

  DateTime? startDate;
  TextEditingController? startDateHourController = TextEditingController();
  TextEditingController? startDateMinuteController = TextEditingController();
  bool? startDateIsWholeDay = true;

  DateTime? endDate;
  TextEditingController? endDateHourController = TextEditingController();
  TextEditingController? endDateMinuteController = TextEditingController();
  bool? endDateIsWholeDay = true;

  TextEditingController? totalHourController = TextEditingController();
  TextEditingController? totalMinuteController = TextEditingController();

  LeaveTypes? leaveTypes;

  UserLeaveHoursFormData({
    this.id,
    this.leaveType,
    this.leaveTypeName,
    this.descriptionController,
    this.startDate,
    this.startDateHourController,
    this.startDateMinuteController,
    this.startDateIsWholeDay,
    this.endDate,
    this.endDateHourController,
    this.endDateMinuteController,
    this.endDateIsWholeDay,
    this.totalHourController,
    this.totalMinuteController,
    this.leaveTypes,
  });

  factory UserLeaveHoursFormData.createFromModel(LeaveTypes leaveTypes, UserLeaveHours leaveHours) {
    final TextEditingController descriptionController = TextEditingController();
    descriptionController.text = leaveHours.description == null ? "" : leaveHours.description!;

    final TextEditingController startDateMinuteController = TextEditingController();
    startDateMinuteController.text = "${leaveHours.startDateMinutes}";
    final TextEditingController startDateHourController = TextEditingController();
    startDateHourController.text = "${leaveHours.startDateHours}";

    final TextEditingController endDateMinuteController = TextEditingController();
    endDateMinuteController.text = "${leaveHours.endDateMinutes}";
    final TextEditingController endDateHourController = TextEditingController();
    endDateHourController.text = "${leaveHours.endDateHours}";

    final TextEditingController totalHourController = TextEditingController();
    totalHourController.text = "${leaveHours.totalHours}";
    final TextEditingController totalMinuteController = TextEditingController();
    totalMinuteController.text = "${leaveHours.totalMinutes}";

    return UserLeaveHoursFormData(
      id: leaveHours.id,
      leaveType: leaveHours.leaveType,
      leaveTypeName: leaveHours.leaveTypeName,
      leaveTypes: leaveTypes,

      startDate: DateFormat('dd/MM/yyyy').parse(leaveHours.startDate!),
      startDateHourController: startDateHourController,
      startDateMinuteController: startDateMinuteController,
      startDateIsWholeDay: leaveHours.startDateIsWholeDay,

      endDate: DateFormat('dd/MM/yyyy').parse(leaveHours.endDate!),
      endDateHourController: endDateHourController,
      endDateMinuteController: endDateMinuteController,
      endDateIsWholeDay: leaveHours.endDateIsWholeDay,

      totalMinuteController: totalMinuteController,
      totalHourController: totalHourController,

      descriptionController: descriptionController,
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
      startDateMinuteController: TextEditingController(),
      startDateHourController: TextEditingController(),
      startDateIsWholeDay: true,

      endDate: DateTime(now.year, now.month, now.day),
      endDateMinuteController: TextEditingController(),
      endDateHourController: TextEditingController(),
      endDateIsWholeDay: true,

      totalHourController: TextEditingController(),
      totalMinuteController: TextEditingController(),

      descriptionController: TextEditingController(),
    );
  }

  UserLeaveHours toModel() {
    int? startDateHours;
    int? startDateMinutes;
    if (!this.startDateIsWholeDay!) {
      if (this.startDateHourController!.text != '') {
        startDateHours = int.parse(this.startDateHourController!.text);
      }

      if (this.startDateMinuteController!.text != '') {
        startDateMinutes = int.parse(this.startDateMinuteController!.text);
      } else {
        if (this.startDateHourController!.text != '') {
          startDateMinutes = 0;
        }
      }
    }

    int? endDateHours;
    int? endDateMinutes;
    if (!this.endDateIsWholeDay!) {
      if (this.endDateHourController!.text != '') {
        endDateHours = int.parse(this.endDateHourController!.text);
      }

      if (this.endDateMinuteController!.text != '') {
        endDateMinutes = int.parse(this.endDateMinuteController!.text);
      } else {
        if (this.endDateHourController!.text != '') {
          endDateMinutes = 0;
        }
      }
    }

    int? totalHours;
    int? totalMinutes;
    if (this.totalHourController!.text != '') {
      totalHours = int.parse(this.totalHourController!.text);
    }

    if (this.totalMinuteController!.text != '') {
      totalMinutes = int.parse(this.totalMinuteController!.text);
    } else {
      if (this.totalHourController!.text != '') {
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
      description: this.descriptionController!.text
    );
  }

  bool isValid() {
    // if (isEmpty(this.descriptionController.text)) {
    //   return false;
    // }

    return true;
  }
}
