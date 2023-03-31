import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'models.dart';

class AssignedOrderWorkOrderFormData extends BaseFormData<AssignedOrderWorkOrder>  {
  int id;
  int assignedOrderId;
  String assignedOrderWorkorderId;

  String userSignature;
  String customerSignature;
  TextEditingController equimentController = TextEditingController();
  TextEditingController descriptionWorkController = TextEditingController();
  TextEditingController customerEmailsController = TextEditingController();
  TextEditingController signatureUserNameController = TextEditingController();
  TextEditingController signatureCustomerNameController = TextEditingController();

  AssignedOrderWorkOrderFormData({
    this.id,
    this.assignedOrderId,
    this.assignedOrderWorkorderId,
    this.userSignature,
    this.customerSignature,
    this.equimentController,
    this.descriptionWorkController,
    this.customerEmailsController,
    this.signatureUserNameController,
    this.signatureCustomerNameController,
  });

  factory AssignedOrderWorkOrderFormData.createFromModel(AssignedOrderWorkOrder workOrder) {
    // we're not using this
    return AssignedOrderWorkOrderFormData();
  }

  factory AssignedOrderWorkOrderFormData.createEmpty(int assignedOrderId, String assignedOrderWorkorderId) {
    return AssignedOrderWorkOrderFormData(
      id: null,
      assignedOrderId: assignedOrderId,
      assignedOrderWorkorderId: assignedOrderWorkorderId,

      userSignature: null,
      customerSignature: null,

      equimentController: TextEditingController(),
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
        descriptionWork: descriptionWorkController.text,
        equipment: equimentController.text,
        signatureUser: userSignature,
        signatureCustomer: customerSignature,
        signatureNameUser: signatureUserNameController.text,
        signatureNameCustomer: signatureCustomerNameController.text,
        customerEmails: customerEmailsController.text,
    );
  }

  bool isValid() {
    return true;
  }
}
