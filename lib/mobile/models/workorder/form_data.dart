import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'models.dart';

class AssignedOrderWorkOrderFormData extends BaseFormData<AssignedOrderWorkOrder>  {
  int? id;
  int? assignedOrderId;
  String? assignedOrderWorkorderId;

  ByteData? imgUser = ByteData(0);
  ByteData? imgCustomer = ByteData(0);
  String? userSignature;
  String? customerSignature;

  TextEditingController? equipmentController = TextEditingController();
  TextEditingController? descriptionWorkController = TextEditingController();
  TextEditingController? customerEmailsController = TextEditingController();
  TextEditingController? signatureUserNameController = TextEditingController();
  TextEditingController? signatureCustomerNameController = TextEditingController();

  AssignedOrderWorkOrderFormData({
    this.id,
    this.assignedOrderId,
    this.assignedOrderWorkorderId,
    this.imgUser,
    this.imgCustomer,
    this.userSignature,
    this.customerSignature,
    this.equipmentController,
    this.descriptionWorkController,
    this.customerEmailsController,
    this.signatureUserNameController,
    this.signatureCustomerNameController,
  });

  factory AssignedOrderWorkOrderFormData.createFromModel(AssignedOrderWorkOrder workOrder) {
    // we're not using this
    return AssignedOrderWorkOrderFormData();
  }

  factory AssignedOrderWorkOrderFormData.createEmpty(int? assignedOrderId) {
    return AssignedOrderWorkOrderFormData(
      id: null,
      assignedOrderId: assignedOrderId,
      assignedOrderWorkorderId: null,

      userSignature: null,
      customerSignature: null,
      imgUser: ByteData(0),
      imgCustomer: ByteData(0),

      equipmentController: TextEditingController(),
      descriptionWorkController: TextEditingController(),
      customerEmailsController: TextEditingController(),
      signatureUserNameController: TextEditingController(),
      signatureCustomerNameController: TextEditingController(),
    );
  }

  AssignedOrderWorkOrder toModel() {
    return AssignedOrderWorkOrder(
        id: this.id,
        assignedOrderId: assignedOrderId,
        assignedOrderWorkorderId: assignedOrderWorkorderId,
        descriptionWork: descriptionWorkController!.text,
        equipment: equipmentController!.text,
        signatureUser: userSignature,
        signatureCustomer: customerSignature,
        signatureNameUser: signatureUserNameController!.text,
        signatureNameCustomer: signatureCustomerNameController!.text,
        customerEmails: customerEmailsController!.text,
    );
  }

  bool isValid() {
    return userSignature != null && customerSignature != null;
  }
}
