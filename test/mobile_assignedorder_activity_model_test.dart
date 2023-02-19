import 'package:flutter_test/flutter_test.dart';
import 'package:my24app/mobile/models/activity/models.dart';
import 'package:my24app/mobile/models/activity/form_data.dart';

void main() {
  test('Test form data to model, valid basic fields', () {
    AssignedOrderActivityFormData formData = AssignedOrderActivityFormData
        .createEmpty(1);
    formData.workStartHourController.text = "08";
    formData.workStartMin = "15";
    formData.workEndHourController.text = "16";
    formData.workEndMin = "15";
    formData.travelToHourController.text = "1";
    formData.travelToMin = "15";
    formData.travelBackHourController.text = "2";
    formData.travelBackMin = "15";
    formData.distanceToController.text = "15";
    formData.distanceBackController.text = "25";
    expect(true, formData.isValid());

    AssignedOrderActivity activity = formData.toModel();
    expect(activity.workStart, "08:15:00");
    expect(activity.workEnd, "16:15:00");
    expect(activity.travelTo, "1:15:00");
    expect(activity.travelBack, "2:15:00");
    expect(activity.distanceTo, 15);
    expect(activity.distanceBack, 25);
    expect(activity.actualWork, null);
    expect(activity.extraWork, null);
    expect(activity.extraWorkDescription, null);
  });

  test('Test form data to model, invalid', () {
    AssignedOrderActivityFormData formData = AssignedOrderActivityFormData
        .createEmpty(1);
    formData.workStartHourController.text = "00";
    formData.workStartMin = "00";
    formData.workEndHourController.text = "00";
    formData.travelToMin = "00";
    formData.travelBackHourController.text = "0";
    formData.travelBackMin = "0";
    expect(formData.isValid(), false);
  });

  test('Test form data to model, valid extra work', () {
    AssignedOrderActivityFormData formData = AssignedOrderActivityFormData
        .createEmpty(1);
    formData.workStartHourController.text = "08";
    formData.workStartMin = "15";
    formData.workEndHourController.text = "16";
    formData.workEndMin = "15";
    formData.travelToHourController.text = "1";
    formData.travelToMin = "15";
    formData.travelBackHourController.text = "2";
    formData.travelBackMin = "15";
    formData.distanceToController.text = "15";
    formData.distanceBackController.text = "25";
    formData.extraWorkHourController.text = "2";
    formData.extraWorkMin = "10";
    expect(true, formData.isValid());

    AssignedOrderActivity activity = formData.toModel();
    expect(activity.workStart, "08:15:00");
    expect(activity.workEnd, "16:15:00");
    expect(activity.travelTo, "1:15:00");
    expect(activity.travelBack, "2:15:00");
    expect(activity.distanceTo, 15);
    expect(activity.distanceBack, 25);
    expect(activity.actualWork, null);
    expect(activity.extraWork, "2:10:00");
    expect(activity.extraWorkDescription, '');
  });

  test('Test form data to model, valid actual work', () {
    AssignedOrderActivityFormData formData = AssignedOrderActivityFormData
        .createEmpty(1);
    formData.workStartHourController.text = "08";
    formData.workStartMin = "15";
    formData.workEndHourController.text = "16";
    formData.workEndMin = "15";
    formData.travelToHourController.text = "1";
    formData.travelToMin = "15";
    formData.travelBackHourController.text = "2";
    formData.travelBackMin = "15";
    formData.distanceToController.text = "15";
    formData.distanceBackController.text = "25";
    formData.actualWorkHourController.text = "7";
    formData.actualWorkMin = "55";
    expect(true, formData.isValid());

    AssignedOrderActivity activity = formData.toModel();
    expect(activity.workStart, "08:15:00");
    expect(activity.workEnd, "16:15:00");
    expect(activity.travelTo, "1:15:00");
    expect(activity.travelBack, "2:15:00");
    expect(activity.distanceTo, 15);
    expect(activity.distanceBack, 25);
    expect(activity.actualWork, "7:55:00");
    expect(activity.extraWork, null);
    expect(activity.extraWorkDescription, null);
  });

  test('Test form data to model, valid null to zero', () {
    AssignedOrderActivityFormData formData = AssignedOrderActivityFormData
        .createEmpty(1);
    formData.workStartHourController.text = "08";
    formData.workStartMin = "15";
    formData.workEndHourController.text = "16";
    formData.workEndMin = "15";
    formData.travelToHourController.text = "1";
    formData.travelToMin = "15";
    formData.travelBackHourController.text = "2";
    formData.travelBackMin = "15";
    formData.distanceToController.text = "15";
    formData.distanceBackController.text = "25";
    formData.actualWorkHourController.text = "7";
    expect(true, formData.isValid());

    AssignedOrderActivity activity = formData.toModel();
    expect(activity.workStart, "08:15:00");
    expect(activity.workEnd, "16:15:00");
    expect(activity.travelTo, "1:15:00");
    expect(activity.travelBack, "2:15:00");
    expect(activity.distanceTo, 15);
    expect(activity.distanceBack, 25);
    expect(activity.actualWork, "7:00:00");
    expect(activity.extraWork, null);
    expect(activity.extraWorkDescription, null);
  });

}
