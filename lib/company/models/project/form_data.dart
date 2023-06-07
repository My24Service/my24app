import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'models.dart';

class ProjectFormData extends BaseFormData<Project>  {
  int? id;
  TextEditingController? nameController;

  ProjectFormData({
    this.id,
    this.nameController,
  });

  factory ProjectFormData.createFromModel(Project project) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = project.name!;

    return ProjectFormData(
      id: project.id,
      nameController: nameController,
    );
  }

  factory ProjectFormData.createEmpty() {
    return ProjectFormData(
      id: null,
      nameController: TextEditingController(),
    );
  }

  Project toModel() {
    return Project(
      id: this.id,
      name: this.nameController!.text,
    );
  }

  bool isValid() {
    if (isEmpty(this.nameController!.text)) {
      return false;
    }

    return true;
  }
}
