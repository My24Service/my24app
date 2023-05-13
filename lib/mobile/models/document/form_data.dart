import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'models.dart';

class AssignedOrderDocumentFormData extends BaseFormData<AssignedOrderDocument>  {
  int id;
  int assignedOrderId;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  File documentFile;

  AssignedOrderDocumentFormData({
    this.id,
    this.assignedOrderId,
    this.documentFile,
    this.nameController,
    this.descriptionController,
    this.documentController
  });

  bool isValid() {
    if (assignedOrderId == null) {
      return false;
    }

    if (nameController.text == null) {
      return false;
    }

    if (documentFile == null) {
      return false;
    }

    return true;
  }

  Future<File> getLocalFile(String path) async {
    return File(path);
  }

  factory AssignedOrderDocumentFormData.createFromModel(AssignedOrderDocument document) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = document.name;
    final TextEditingController descriptionController = TextEditingController();
    descriptionController.text = document.description;
    final TextEditingController documentController = TextEditingController();
    documentController.text = document.document;

    return AssignedOrderDocumentFormData(
      id: document.id,
      assignedOrderId: document.assignedOrderId,
        documentFile: null,
        nameController: nameController,
        descriptionController: descriptionController,
        documentController: documentController
    );
  }

  factory AssignedOrderDocumentFormData.createEmpty(int assignedOrderId) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController documentController = TextEditingController();

    return AssignedOrderDocumentFormData(
      id: null,
      assignedOrderId: assignedOrderId,
        documentFile: null,
        nameController: nameController,
        descriptionController: descriptionController,
        documentController: documentController
    );
  }

  AssignedOrderDocument toModel() {
    return AssignedOrderDocument(
      id: this.id,
      assignedOrderId: this.assignedOrderId,
      name: nameController.text,
      description: descriptionController.text,
      document: base64Encode(documentFile.readAsBytesSync()),
    );
  }
}
