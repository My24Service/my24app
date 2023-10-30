import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'package:my24app/core/utils.dart';
import 'models.dart';

class AssignedOrderActivityFormData extends BaseFormData<AssignedOrderActivity>  {
  int? id;
  int? assignedOrderId;

  String? workStartMin;
  TextEditingController? workStartHourController;
  String? workEndMin;
  TextEditingController? workEndHourController;

  String? travelToMin;
  TextEditingController? travelToHourController;
  String? travelBackMin;
  TextEditingController? travelBackHourController;

  TextEditingController? distanceToController;
  TextEditingController? distanceBackController;

  String? extraWorkMin;
  TextEditingController? extraWorkHourController;
  TextEditingController? extraWorkDescriptionController;

  TextEditingController? actualWorkHourController;
  String? actualWorkMin;
  bool? showActualWork;

  DateTime? activityDate;

  AssignedOrderActivityFormData({
    this.id,
    this.assignedOrderId,

    this.workStartHourController,
    this.workEndHourController,
    this.workStartMin,
    this.workEndMin,

    this.travelToHourController,
    this.travelBackHourController,
    this.travelToMin,
    this.travelBackMin,

    this.distanceToController,
    this.distanceBackController,

    this.extraWorkMin,
    this.extraWorkHourController,
    this.extraWorkDescriptionController,

    this.actualWorkHourController,
    this.actualWorkMin,
    this.showActualWork,

    this.activityDate,
  });

  factory AssignedOrderActivityFormData.createFromModel(AssignedOrderActivity activity) {
    HourMin workStartHourMin = HourMin.fromString(activity.workStart!);
    HourMin workEndHourMin = HourMin.fromString(activity.workEnd!);

    final TextEditingController workStartHourController = TextEditingController();
    workStartHourController.text = workStartHourMin.hours!;
    final TextEditingController workEndHourController = TextEditingController();
    workEndHourController.text = workEndHourMin.hours!;

    HourMin travelToHourMin = HourMin.fromString(activity.travelTo!);

    final TextEditingController travelToHourController = TextEditingController();
    travelToHourController.text = travelToHourMin.hours!;

    HourMin travelBackHourMin = HourMin.fromString(activity.travelBack!);
    final TextEditingController travelBackHourController = TextEditingController();
    travelBackHourController.text = travelBackHourMin.hours!;

    final TextEditingController distanceToController = TextEditingController();
    distanceToController.text = "${activity.distanceTo}";
    final TextEditingController distanceBackController = TextEditingController();
    distanceBackController.text = "${activity.distanceBack}";

    final TextEditingController actualWorkHourController = TextEditingController();
    String? actualWorkMin;
    bool showActualWork = false;
    if (activity.actualWork != null) {
      HourMin actualWorkHourMin = HourMin.fromString(activity.actualWork!);
      actualWorkHourController.text = actualWorkHourMin.hours!;
      actualWorkMin = actualWorkHourMin.minutes;
      showActualWork = true;
    }

    final TextEditingController extraWorkHourController = TextEditingController();
    String? extraWorkMin;
    if (activity.extraWork != null) {
      HourMin extraWorkHourMin = HourMin.fromString(activity.extraWork!);
      extraWorkHourController.text = extraWorkHourMin.hours!;
      extraWorkMin = extraWorkHourMin.minutes;
    }

    final TextEditingController extraWorkDescriptionController = TextEditingController();
    extraWorkDescriptionController.text = activity.extraWorkDescription == null ? "" : activity.extraWorkDescription!;

    return AssignedOrderActivityFormData(
      id: activity.id,
      assignedOrderId: activity.assignedOrderId,

      workStartMin: workStartHourMin.minutes,
      workStartHourController: workStartHourController,
      workEndMin: workEndHourMin.minutes,
      workEndHourController: workEndHourController,

      travelToMin: travelToHourMin.minutes,
      travelToHourController: travelToHourController,
      travelBackMin: travelBackHourMin.minutes,
      travelBackHourController: travelBackHourController,

      distanceToController: distanceToController,
      distanceBackController: distanceBackController,

      actualWorkMin: actualWorkMin,
      actualWorkHourController: actualWorkHourController,
      showActualWork: showActualWork,

      extraWorkMin: extraWorkMin,
      extraWorkHourController: extraWorkHourController,
      extraWorkDescriptionController: extraWorkDescriptionController,

      activityDate: getDateTimeFromString(activity.activityDate!),
    );
  }

  factory AssignedOrderActivityFormData.createEmpty(int? assignedOrderId) {
    TextEditingController distanceToController = TextEditingController();
    distanceToController.text = "0";

    TextEditingController distanceBackController = TextEditingController();
    distanceBackController.text = "0";

    TextEditingController workStartHourController = TextEditingController();
    workStartHourController.text = "0";

    TextEditingController workEndHourController = TextEditingController();
    workEndHourController.text = "0";

    TextEditingController travelToHourController = TextEditingController();
    travelToHourController.text = "0";

    TextEditingController travelBackHourController = TextEditingController();
    travelBackHourController.text = "0";

    TextEditingController actualWorkHourController = TextEditingController();
    actualWorkHourController.text = "0";

    TextEditingController extraWorkHourController = TextEditingController();
    extraWorkHourController.text = "0";

    return AssignedOrderActivityFormData(
      id: null,
      assignedOrderId: assignedOrderId,

      workStartMin: "00",
      workStartHourController: workStartHourController,
      workEndMin: "00",
      workEndHourController: workEndHourController,

      travelToMin: "00",
      travelToHourController: travelToHourController,
      travelBackMin: "00",
      travelBackHourController: travelBackHourController,

      distanceToController: distanceToController,
      distanceBackController: distanceBackController,

      actualWorkMin: "00",
      actualWorkHourController: actualWorkHourController,
      showActualWork: false,

      extraWorkMin: "00",
      extraWorkHourController: extraWorkHourController,
      extraWorkDescriptionController: TextEditingController(),

      activityDate: DateTime.now(),
    );
  }

  AssignedOrderActivity toModel() {
    // extra work
    String? extraWork;
    String? extraWorkDescription;

    if (!isEmpty(this.extraWorkHourController!.text) || !isEmpty(this.extraWorkMin)) {
      extraWork = hourMinToTimestring(this.extraWorkHourController!.text, this.extraWorkMin);
      extraWorkDescription = this.extraWorkDescriptionController!.text;
    }

    // actual work
    String? actualWork;
    if (!isEmpty(this.actualWorkHourController!.text) || !isEmpty(this.actualWorkMin)) {
      actualWork = hourMinToTimestring(this.actualWorkHourController!.text, this.actualWorkMin);
    }

    return AssignedOrderActivity(
      id: this.id,
      assignedOrderId: this.assignedOrderId,
      activityDate: utils.formatDate(this.activityDate!),
      workStart: hourMinToTimestring(this.workStartHourController!.text, this.workStartMin),
      workEnd: hourMinToTimestring(this.workEndHourController!.text, this.workEndMin),
      travelTo: hourMinToTimestring(this.travelToHourController!.text, this.travelToMin),
      travelBack: hourMinToTimestring(this.travelBackHourController!.text, this.travelBackMin),
      distanceTo: int.parse(this.distanceToController!.text),
      distanceBack: int.parse(this.distanceBackController!.text),
      extraWork: extraWork,
      extraWorkDescription: extraWorkDescription,
      actualWork: actualWork,
    );
  }

  bool isValid() {
    if (isEmpty(this.workStartHourController!.text) && isEmpty(this.workStartMin) &&
        isEmpty(this.workEndHourController!.text) && isEmpty(this.workEndMin) &&
        isEmpty(this.travelToHourController!.text) && isEmpty(this.travelToMin) &&
        isEmpty(this.travelBackHourController!.text) &&
        isEmpty(this.travelBackMin) &&
        isEmpty(this.distanceToController!.text) &&
        isEmpty(this.distanceBackController!.text)
    ) {
      return false;
    }

    return true;
  }
}
