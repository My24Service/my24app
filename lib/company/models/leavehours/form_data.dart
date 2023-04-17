import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/company/models/leave_type/models.dart';

class UserLeaveHoursFormData extends BaseFormData<UserLeaveHours>  {
  int id;
  int leaveType;
  String leaveTypeName;

  TextEditingController descriptionController = TextEditingController();

  DateTime startDate;
  TextEditingController startDateHourController = TextEditingController();
  String startDateMinutes = '00';
  bool startDateIsWholeDay = true;

  DateTime endDate;
  TextEditingController endDateHourController = TextEditingController();
  String endDateMinutes = '00';
  bool endDateIsWholeDay = true;

  TextEditingController totalHourController = TextEditingController();
  String totalMinutes = '00';

  LeaveTypes leaveTypes;

  UserLeaveHoursFormData({
    this.id,
    this.leaveType,
    this.leaveTypeName,
    this.descriptionController,
    this.startDate,
    this.startDateHourController,
    this.startDateMinutes,
    this.startDateIsWholeDay,
    this.endDate,
    this.endDateHourController,
    this.endDateMinutes,
    this.endDateIsWholeDay,
    this.totalHourController,
    this.totalMinutes,
    this.leaveTypes
  });

  factory UserLeaveHoursFormData.createFromModel(LeaveTypes leaveTypes, UserLeaveHours leaveHours) {
    final TextEditingController descriptionController = TextEditingController();
    descriptionController.text = leaveHours.description;

    final TextEditingController startDateHourController = TextEditingController();
    startDateHourController.text = "${leaveHours.startDateHours}";

    final TextEditingController endDateHourController = TextEditingController();
    endDateHourController.text = "${leaveHours.endDateHours}";

    final TextEditingController totalHourController = TextEditingController();
    totalHourController.text = "${leaveHours.totalHours}";

    final String startDateMinutes = leaveHours.startDateMinutes == null ? "00" : "${leaveHours.startDateMinutes}";
    final String endDateMinutes = leaveHours.endDateMinutes == null ? "00" : "${leaveHours.endDateMinutes}";

    return UserLeaveHoursFormData(
      id: leaveHours.id,
      leaveType: leaveHours.leaveType,
      leaveTypeName: leaveHours.leaveTypeName,
      leaveTypes: leaveTypes,

      startDate: DateFormat('dd/MM/yyyy').parse(leaveHours.startDate),
      startDateHourController: startDateHourController,
      startDateMinutes: startDateMinutes,
      startDateIsWholeDay: leaveHours.startDateIsWholeDay,

      endDate: DateFormat('dd/MM/yyyy').parse(leaveHours.endDate),
      endDateHourController: endDateHourController,
      endDateMinutes: endDateMinutes,
      endDateIsWholeDay: leaveHours.endDateIsWholeDay,

      totalHourController: totalHourController,
      totalMinutes: "${leaveHours.totalMinutes}",

      descriptionController: descriptionController,
    );
  }

  factory UserLeaveHoursFormData.createEmpty(LeaveTypes leaveTypes) {
    return UserLeaveHoursFormData(
      id: null,
      leaveType: leaveTypes.results.length > 0 ? leaveTypes.results[0].id : null,
      leaveTypeName: leaveTypes.results.length > 0 ? leaveTypes.results[0].name : null,
      leaveTypes: leaveTypes,

      startDate: DateTime.now(),
      startDateMinutes: "00",
      startDateHourController: TextEditingController(),
      startDateIsWholeDay: true,

      endDate: DateTime.now(),
      endDateMinutes: "00",
      endDateHourController: TextEditingController(),
      endDateIsWholeDay: true,

      totalHourController: TextEditingController(),
      totalMinutes: "00",

      descriptionController: TextEditingController(),
    );
  }

  UserLeaveHours toModel() {
    int startDateHours;
    int startDateMinutes;
    if (!this.startDateIsWholeDay) {
      if (this.startDateHourController.text != null) {
        startDateHours = int.parse(this.startDateHourController.text);
      }

      startDateMinutes = int.parse(this.startDateMinutes);
    }

    int endDateHours;
    int endDateMinutes;
    if (!this.endDateIsWholeDay) {
      if (this.endDateHourController.text != null) {
        endDateHours = int.parse(this.endDateHourController.text);
      }

      endDateMinutes = int.parse(this.endDateMinutes);
    }

    int totalHours;
    if (this.totalHourController.text != null) {
      totalHours = int.parse(this.totalHourController.text);
    }
    int totalMinutes = int.parse(this.totalMinutes);

    return UserLeaveHours(
      id: this.id,
      leaveType: this.leaveType,
      startDate: utils.formatDate(this.startDate),
      startDateHours: startDateHours,
      startDateMinutes: startDateMinutes,
      startDateIsWholeDay: this.startDateIsWholeDay,
      endDate: utils.formatDate(this.endDate),
      endDateHours: endDateHours,
      endDateMinutes: endDateMinutes,
      endDateIsWholeDay: this.endDateIsWholeDay,
      totalHours: totalHours,
      totalMinutes: totalMinutes,
      description: this.descriptionController.text
    );
  }

  bool isValid() {
    // if (isEmpty(this.descriptionController.text)) {
    //   return false;
    // }

    return true;
  }
}
