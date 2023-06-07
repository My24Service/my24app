import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/models/project/models.dart';
import 'models.dart';

class UserWorkHoursFormData extends BaseFormData<UserWorkHours>  {
  int? id;
  int? project;
  String? projectName;

  TextEditingController? descriptionController = TextEditingController();
  TextEditingController? workStartHourController = TextEditingController();
  TextEditingController? workEndHourController = TextEditingController();
  TextEditingController? travelToHourController = TextEditingController();
  TextEditingController? travelBackHourController = TextEditingController();
  TextEditingController? distanceToController = TextEditingController();
  TextEditingController? distanceBackController = TextEditingController();

  String? workStartMin = '00';
  String? workEndMin = '00';
  String? travelToMin = '00';
  String? travelBackMin = '00';

  DateTime? startDate;

  Projects? projects;

  UserWorkHoursFormData({
    this.id,
    this.project,
    this.projectName,
    this.descriptionController,
    this.workStartHourController,
    this.workEndHourController,
    this.travelToHourController,
    this.travelBackHourController,
    this.distanceToController,
    this.distanceBackController,
    this.workStartMin,
    this.workEndMin,
    this.travelToMin,
    this.travelBackMin,
    this.startDate,
    this.projects
  });

  factory UserWorkHoursFormData.createFromModel(Projects projects, UserWorkHours workHours) {
    final TextEditingController descriptionController = TextEditingController();
    descriptionController.text = workHours.description == null ? "" : workHours.description!;

    HourMin workStartHourMin = HourMin.fromString(workHours.workStart!);
    HourMin workEndHourMin = HourMin.fromString(workHours.workEnd!);

    final TextEditingController workStartHourController = TextEditingController();
    workStartHourController.text = workStartHourMin.hours!;
    final TextEditingController workEndHourController = TextEditingController();
    workEndHourController.text = workEndHourMin.hours!;

    HourMin travelToHourMin = HourMin.fromString(workHours.travelTo!);
    final TextEditingController travelToHourController = TextEditingController();
    travelToHourController.text = travelToHourMin.hours!;

    HourMin travelBackHourMin = HourMin.fromString(workHours.travelBack!);
    final TextEditingController travelBackHourController = TextEditingController();
    travelBackHourController.text = travelBackHourMin.hours!;

    final TextEditingController distanceToController = TextEditingController();
    distanceToController.text = "${workHours.distanceTo}";
    final TextEditingController distanceBackController = TextEditingController();
    distanceBackController.text = "${workHours.distanceBack}";

    return UserWorkHoursFormData(
      id: workHours.id,
      project: workHours.project,
      projectName: workHours.projectName,
      projects: projects,

      startDate: DateFormat('dd/MM/yyyy').parse(workHours.startDate!),

      descriptionController: descriptionController,

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
    );
  }

  factory UserWorkHoursFormData.createEmpty(Projects projects) {
    return UserWorkHoursFormData(
      id: null,
      project: projects.results!.length > 0 ? projects.results![0].id : null,
      projectName: projects.results!.length > 0 ? projects.results![0].name : null,
      projects: projects,

      startDate: DateTime.now(),

      workStartMin: "00",
      workStartHourController: TextEditingController(),
      workEndMin: "00",
      workEndHourController: TextEditingController(),

      travelToMin: "00",
      travelToHourController: TextEditingController(),
      travelBackMin: "00",
      travelBackHourController: TextEditingController(),

      distanceToController: TextEditingController(),
      distanceBackController: TextEditingController(),
    );
  }

  UserWorkHours toModel() {
    int _distanceTo = distanceToController!.text == null || distanceToController!.text == "" ? 0 : int.parse(distanceToController!.text);
    int _distanceBack = distanceBackController!.text == null || distanceBackController!.text == "" ? 0 : int.parse(distanceBackController!.text);

    return UserWorkHours(
      id: this.id,
      project: this.project,
      startDate: utils.formatDate(this.startDate!),
      workStart: hourMinToTimestring(this.workStartHourController!.text, this.workStartMin),
      workEnd: hourMinToTimestring(this.workEndHourController!.text, this.workEndMin),
      travelTo: hourMinToTimestring(this.travelToHourController!.text, this.travelToMin),
      travelBack: hourMinToTimestring(this.travelBackHourController!.text, this.travelBackMin),
      distanceTo: _distanceTo,
      distanceBack: _distanceBack,
    );
  }

  bool isValid() {
    if (isEmpty(this.workStartHourController!.text) && isEmpty(this.workStartMin) &&
        isEmpty(this.workEndHourController!.text) && isEmpty(this.workEndMin)
    ) {
      return false;
    }

    return true;
  }
}
