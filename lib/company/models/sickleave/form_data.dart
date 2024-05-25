import 'package:easy_localization/easy_localization.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24app/company/models/sickleave/models.dart';

class UserSickLeaveFormData extends BaseFormData<UserSickLeave>  {
  int? id;
  DateTime? startDate;
  DateTime? endDate;

  UserSickLeaveFormData({
    this.id,
    this.startDate,
    this.endDate,
  });

  factory UserSickLeaveFormData.createFromModel(UserSickLeave sickLeave) {
    return UserSickLeaveFormData(
      id: sickLeave.id,
      startDate: DateFormat('dd/MM/yyyy').parse(sickLeave.startDate!),
      endDate: sickLeave.endDate == null ? null : DateFormat('dd/MM/yyyy').parse(sickLeave.endDate!),
    );
  }

  factory UserSickLeaveFormData.createEmpty() {
    DateTime now = DateTime.now();

    return UserSickLeaveFormData(
      id: null,
      startDate: DateTime(now.year, now.month, now.day),
      endDate: null,
    );
  }

  UserSickLeave toModel() {
    return UserSickLeave(
      id: this.id,
      startDate: coreUtils.formatDate(this.startDate!),
      endDate: coreUtils.formatDate(this.endDate!),
    );
  }

  bool isValid() {
    // if (isEmpty(this.descriptionController.text)) {
    //   return false;
    // }

    return true;
  }
}
