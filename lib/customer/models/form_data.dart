import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'models.dart';

class CustomerFormData extends BaseFormData<Customer>  {
  int id;
  String customerId;
  String countryCode = 'NL';

  TextEditingController customerIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postalController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

  CustomerFormData({
    this.id,
    this.customerId,
    this.countryCode,
    this.customerIdController,
    this.nameController,
    this.addressController,
    this.postalController,
    this.cityController,
    this.emailController,
    this.telController,
    this.mobileController,
    this.contactController,
    this.remarksController,
  });

  factory CustomerFormData.createFromModel(Customer customer) {
    final TextEditingController customerIdController = TextEditingController();
    customerIdController.text = customer.customerId;

    final TextEditingController nameController = TextEditingController();
    nameController.text = customer.name;
    final TextEditingController addressController = TextEditingController();
    addressController.text = customer.address;
    final TextEditingController postalController = TextEditingController();
    postalController.text = customer.postal;
    final TextEditingController cityController = TextEditingController();
    cityController.text = customer.city;
    final TextEditingController emailController = TextEditingController();
    emailController.text = customer.email;
    final TextEditingController telController = TextEditingController();
    telController.text = customer.tel;
    final TextEditingController mobileController = TextEditingController();
    mobileController.text = customer.mobile;
    final TextEditingController contactController = TextEditingController();
    contactController.text = customer.contact;
    final TextEditingController remarksController = TextEditingController();
    remarksController.text = customer.remarks;

    return CustomerFormData(
      id: customer.id,
      countryCode: customer.countryCode,
      customerIdController: customerIdController,
      nameController: nameController,
      addressController: addressController,
      postalController: postalController,
      cityController: cityController,
      emailController: emailController,
      telController: telController,
      mobileController: mobileController,
      contactController: contactController,
      remarksController: remarksController,
    );
  }

  factory CustomerFormData.createEmpty(String customerId) {
    final TextEditingController customerIdController = TextEditingController();
    customerIdController.text = customerId;

    return CustomerFormData(
      id: null,
      customerId: customerId,
      countryCode: "NL",
      customerIdController: customerIdController,
      nameController: TextEditingController(),
      addressController: TextEditingController(),
      postalController: TextEditingController(),
      cityController: TextEditingController(),
      emailController: TextEditingController(),
      telController: TextEditingController(),
      mobileController: TextEditingController(),
      contactController: TextEditingController(),
      remarksController: TextEditingController(),
    );
  }

  Customer toModel() {
    return Customer(
      id: this.id,
      customerId: this.customerId,
      name: nameController.text,
      address: addressController.text,
      postal: postalController.text,
      city: cityController.text,
      countryCode: countryCode,
      email: emailController.text,
      tel: telController.text,
      mobile: mobileController.text,
      contact: contactController.text,
      remarks: remarksController.text,
    );
  }

  bool isValid() {
    if (isEmpty(this.customerId)) {
      return false;
    }

    return true;
  }
}
