import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'models.dart';

class LeaveTypeFormData extends BaseFormData<LeaveType>  {
  int id;
  TextEditingController nameController;
  bool countsAsLeave;

  LeaveTypeFormData({
    this.id,
    this.nameController,
    this.countsAsLeave
  });

  factory LeaveTypeFormData.createFromModel(LeaveType leaveType) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = leaveType.name;

    return LeaveTypeFormData(
      id: leaveType.id,
      nameController: nameController,
      countsAsLeave: leaveType.countsAsLeave
    );
  }

  factory LeaveTypeFormData.createEmpty() {
    return LeaveTypeFormData(
      id: null,
      nameController: TextEditingController(),
      countsAsLeave: true,
    );
  }

  LeaveType toModel() {
    return LeaveType(
      id: this.id,
      name: this.nameController.text,
      countsAsLeave: this.countsAsLeave
    );
  }

  bool isValid() {
    if (isEmpty(this.nameController.text)) {
      return false;
    }

    return true;
  }
}
