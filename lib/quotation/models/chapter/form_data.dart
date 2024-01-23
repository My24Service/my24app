import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'models.dart';

class ChapterFormData extends BaseFormData<Chapter> {
  int? id;
  int? quotation;
  String? name;
  String? description;

  bool isValid() {
    return true;
  }

  dynamic getProp(String key) => <String, dynamic>{
        'name': name,
        'description': description,
      }[key];

  dynamic setProp(String key, String value) {
    switch (key) {
      case 'name':
        this.name = value;
        break;
      case 'description':
        this.description = value;
        break;
      default:
        throw Exception("unknown field: $key");
    }
  }

  ChapterFormData({this.id, this.quotation, this.name, this.description});

  @override
  Chapter toModel() {
    return Chapter(
      id: id,
      quotation: quotation,
      name: name,
      description: description,
    );
  }

  factory ChapterFormData.createEmpty() {
    return ChapterFormData(
        id: null, quotation: null, name: null, description: null);
  }

  factory ChapterFormData.createFromModel(Chapter chapter) {
    return ChapterFormData(
        id: chapter.id,
        quotation: chapter.quotation,
        name: chapter.name,
        description: chapter.description);
  }
}
