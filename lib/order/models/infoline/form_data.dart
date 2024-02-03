import 'package:flutter/cupertino.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'models.dart';

class InfolineFormData extends BaseFormData<Infoline> {
  int? id;

  TextEditingController? infoController = TextEditingController();

  bool isValid() {
    if (infoController!.text == "") {
      return false;
    }

    return true;
  }

  @override
  Infoline toModel() {
    Infoline infoline = Infoline(
        id: id,
        info: infoController!.text,
    );

    return infoline;
  }

  factory InfolineFormData.createEmpty() {
    TextEditingController? infoController = TextEditingController();

    return InfolineFormData(
      id: null,
      infoController: infoController,
   );
  }

  factory InfolineFormData.createFromModel(Infoline infoline) {
    TextEditingController? infoController = TextEditingController();
    infoController.text = infoline.info != null ? infoline.info! : "";

    return InfolineFormData(
      id: infoline.id,
      infoController: infoController,
    );
  }

  InfolineFormData({
      this.id,
      this.infoController,
  });
}
