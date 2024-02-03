import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my24_flutter_core/models/base_models.dart';
import 'models.dart';

class OrderDocumentFormData extends BaseFormData<OrderDocument> {
  int? id;
  int? orderId;
  TextEditingController? nameController = TextEditingController();
  TextEditingController? descriptionController = TextEditingController();
  TextEditingController? documentController = TextEditingController();
  File? documentFile;

  bool isValid() {
    if (orderId == null) {
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

  @override
  OrderDocument toModel() {
    return OrderDocument(
      orderId: orderId,
      name: nameController!.text,
      description: descriptionController!.text,
      file: base64Encode(documentFile!.readAsBytesSync()),
    );
  }

  factory OrderDocumentFormData.createEmpty(int orderId) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController documentController = TextEditingController();

    return OrderDocumentFormData(
        id: null,
        orderId: orderId,
        documentFile: null,
        nameController: nameController,
        descriptionController: descriptionController,
        documentController: documentController
    );
  }

  factory OrderDocumentFormData.createFromModel(OrderDocument document) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = checkNull(document.name);
    final TextEditingController descriptionController = TextEditingController();
    descriptionController.text = checkNull(document.description);
    final TextEditingController documentController = TextEditingController();
    documentController.text = checkNull(document.file);

    return OrderDocumentFormData(
        id: null,
        orderId: null,
        documentFile: null,
        nameController: nameController,
        descriptionController: descriptionController,
        documentController: documentController
    );
  }

  OrderDocumentFormData({
    this.id,
    this.orderId,
    this.documentFile,
    this.nameController,
    this.descriptionController,
    this.documentController
  });
}
