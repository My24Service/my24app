import 'package:flutter/cupertino.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'models.dart';

class OrderlineFormData extends BaseFormData<Orderline> {
  int? id;
  int? equipment;
  int? equipmentLocation;

  TextEditingController? locationController = TextEditingController();
  TextEditingController? productController = TextEditingController();
  TextEditingController? remarksController = TextEditingController();

  TextEditingController? typeAheadControllerEquipment = TextEditingController();
  TextEditingController? typeAheadControllerEquipmentLocation = TextEditingController();

  bool isValid() {
    if (productController!.text == "") {
      return false;
    }

    return true;
  }

  @override
  Orderline toModel() {
    Orderline orderline = Orderline(
        id: id,
        product: productController!.text,
        location: locationController!.text,
        remarks: remarksController!.text,
        equipment: equipment,
        equipmentLocation: equipmentLocation,
    );

    return orderline;
  }

  factory OrderlineFormData.createEmpty() {
    TextEditingController? locationController = TextEditingController();
    TextEditingController? productController = TextEditingController();
    TextEditingController? remarksController = TextEditingController();

    TextEditingController? typeAheadControllerEquipment = TextEditingController();
    TextEditingController? typeAheadControllerEquipmentLocation = TextEditingController();

    return OrderlineFormData(
      id: null,
      equipment: null,
      equipmentLocation: null,
      locationController: locationController,
      productController: productController,
      remarksController: remarksController,
      typeAheadControllerEquipment: typeAheadControllerEquipment,
      typeAheadControllerEquipmentLocation: typeAheadControllerEquipmentLocation,
    );
  }

  factory OrderlineFormData.createFromModel(Orderline orderline) {
    TextEditingController? locationController = TextEditingController();
    locationController.text = orderline.location != null ? orderline.location! : "";

    TextEditingController? productController = TextEditingController();
    productController.text = orderline.product != null ? orderline.product! : "";

    TextEditingController? remarksController = TextEditingController();
    remarksController.text = orderline.remarks != null ? orderline.remarks! : "";

    TextEditingController? typeAheadControllerEquipment = TextEditingController();
    TextEditingController? typeAheadControllerEquipmentLocation = TextEditingController();

    return OrderlineFormData(
      id: orderline.id,
      equipment: orderline.equipment,
      equipmentLocation: orderline.equipmentLocation,
      locationController: locationController,
      productController: productController,
      remarksController: remarksController,
      typeAheadControllerEquipment: typeAheadControllerEquipment,
      typeAheadControllerEquipmentLocation: typeAheadControllerEquipmentLocation,
    );
  }

  OrderlineFormData({
      this.id,
      this.equipment,
      this.equipmentLocation,
      this.locationController,
      this.productController,
      this.remarksController,
      this.typeAheadControllerEquipment,
      this.typeAheadControllerEquipmentLocation,
  });
}
