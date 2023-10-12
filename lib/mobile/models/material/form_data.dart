import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'models.dart';

class AssignedOrderMaterialFormData extends BaseFormData<AssignedOrderMaterial>  {
  int? id;
  int? assignedOrderId;
  int? material;
  int? location;
  bool? stockMaterialFound;
  TextEditingController? nameController;
  TextEditingController? identifierController;
  TextEditingController? amountController;
  TextEditingController? typeAheadControllerStock;
  TextEditingController? typeAheadControllerAll;

  AssignedOrderMaterialFormData({
    this.id,
    this.assignedOrderId,
    this.material,
    this.location,
    this.stockMaterialFound,
    this.nameController,
    this.identifierController,
    this.amountController,
    this.typeAheadControllerStock,
    this.typeAheadControllerAll,
  });

  factory AssignedOrderMaterialFormData.createFromModel(AssignedOrderMaterial material) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = checkNull(material.materialName);

    final TextEditingController identifierController = TextEditingController();
    identifierController.text = checkNull(material.materialIdentifier);

    final TextEditingController amountController = TextEditingController();
    amountController.text = "${material.amount!.round()}";

    final TextEditingController typeAheadControllerStock = TextEditingController();
    final TextEditingController typeAheadControllerAll = TextEditingController();

    return AssignedOrderMaterialFormData(
      id: material.id,
      assignedOrderId: material.assignedOrderId,
      material: material.material,
      location: material.location,
      stockMaterialFound: true,

      nameController: nameController,
      identifierController: identifierController,
      amountController: amountController,
      typeAheadControllerStock: typeAheadControllerStock,
      typeAheadControllerAll: typeAheadControllerAll,
    );
  }

  factory AssignedOrderMaterialFormData.createEmpty(int? assignedOrderId) {
    return AssignedOrderMaterialFormData(
      id: null,
      assignedOrderId: assignedOrderId,
      material: null,
      location: null,
      stockMaterialFound: true,

      nameController: TextEditingController(),
      identifierController: TextEditingController(),
      amountController: TextEditingController(),
      typeAheadControllerStock: TextEditingController(),
      typeAheadControllerAll: TextEditingController(),
    );
  }

  AssignedOrderMaterial toModel() {
    double amount = double.parse(this.amountController!.text);
    return AssignedOrderMaterial(
        id: this.id,
        assignedOrderId: this.assignedOrderId,
        material: this.material,
        location: this.location,
        materialName: this.nameController!.text,
        materialIdentifier: this.identifierController!.text,
        amount: amount
    );
  }

  bool isValid() {
    if (isEmpty("${this.material}") || isEmpty("${this.location}")) {
      return false;
    }

    return true;
  }
}
