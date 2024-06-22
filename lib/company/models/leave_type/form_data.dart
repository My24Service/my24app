import 'package:my24_flutter_core/models/base_models.dart';
import 'models.dart';

class LeaveTypeFormData extends BaseFormData<LeaveType>  {
  int? id;
  String? name;
  bool? countsAsLeave;

  dynamic getProp(String key) => <String, dynamic>{
    'name' : name,
  }[key];

  dynamic setProp(String key, String value) {
    switch (key) {
      case 'name': {
          this.name = value;
        }
        break;

      default:
        {
          throw Exception("unknown field: $key");
        }
    }
  }

  LeaveTypeFormData({
    this.id,
    this.name,
    this.countsAsLeave
  });

  factory LeaveTypeFormData.createFromModel(LeaveType leaveType) {
    return LeaveTypeFormData(
      id: leaveType.id,
      name: leaveType.name,
      countsAsLeave: leaveType.countsAsLeave
    );
  }

  factory LeaveTypeFormData.createEmpty() {
    return LeaveTypeFormData(
      id: null,
      name: null,
      countsAsLeave: true,
    );
  }

  LeaveType toModel() {
    return LeaveType(
      id: this.id,
      name: this.name,
      countsAsLeave: this.countsAsLeave
    );
  }

  bool isValid() {
    if (isEmpty(this.name)) {
      return false;
    }

    return true;
  }
}
