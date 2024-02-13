import 'package:flutter/cupertino.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24app/customer/models/models.dart';
import 'models.dart';

class SalesUserCustomerFormData extends BaseFormData<SalesUserCustomer>  {
  int? id;
  int? customer;
  Customer? selectedCustomer;
  TextEditingController? typeAheadController = TextEditingController();

  SalesUserCustomerFormData({
    this.id,
    this.customer,
    this.selectedCustomer,
    this.typeAheadController,
  });

  factory SalesUserCustomerFormData.createFromModel(SalesUserCustomer salesUserCustomer) {
    return SalesUserCustomerFormData(
      id: salesUserCustomer.id,
      customer: salesUserCustomer.customer,
    );
  }

  factory SalesUserCustomerFormData.createEmpty() {
    return SalesUserCustomerFormData(
      id: null,
      customer: null,
    );
  }

  SalesUserCustomer toModel() {
    return SalesUserCustomer(
      id: this.id,
      customer: this.customer,
    );
  }

  bool isValid() {
    if (isEmpty("${this.customer}")) {
      return false;
    }

    return true;
  }
}
