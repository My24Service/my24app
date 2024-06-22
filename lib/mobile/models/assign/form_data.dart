import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24app/company/models/models.dart';

class AssignOrderFormData extends BaseFormData<EngineerUser?> {
  List<int?> selectedEngineerPks = [];

  @override
  EngineerUser? toModel() {
    return null;
  }
}
