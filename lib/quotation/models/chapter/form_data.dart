import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'models.dart';

class ChapterFormData extends BaseFormData<Chapter> {
  int? id;
  int? quotation;

  TextEditingController? nameController = TextEditingController();
  TextEditingController? descriptionController = TextEditingController();

  bool isValid() {
    if (isEmpty(this.nameController!.text)) {
      return false;
    }
    return true;
  }

  ChapterFormData(
      {this.id,
      this.quotation,
      this.nameController,
      this.descriptionController});

  @override
  Chapter toModel() {
    return Chapter(
      id: id,
      quotation: quotation,
      name: nameController!.text,
      description: descriptionController!.text,
    );
  }

  factory ChapterFormData.createEmpty() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    return ChapterFormData(
        id: null,
        quotation: null,
        nameController: nameController,
        descriptionController: descriptionController);
  }

  factory ChapterFormData.createFromModel(Chapter chapter) {
    TextEditingController nameController = TextEditingController();
    nameController.text = checkNull(chapter.name);
    TextEditingController descriptionController = TextEditingController();
    descriptionController.text = checkNull(chapter.description);

    return ChapterFormData(
        id: chapter.id,
        quotation: chapter.quotation,
        nameController: nameController,
        descriptionController: descriptionController);
  }
}
