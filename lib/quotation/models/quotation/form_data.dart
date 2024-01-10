import 'package:flutter/cupertino.dart';

import 'package:my24app/core/models/base_models.dart';
import 'package:my24app/customer/models/models.dart';
import 'models.dart';

class QuotationFormData extends BaseFormData<Quotation> {
  TextEditingController? typeAheadControllerCustomer = TextEditingController();

  int? id;
  int? branch;
  int? customerRelation;
  String? customerId;
  String? quotationCountryCode = 'NL';
  bool quotationAccepted = false;

  TextEditingController? customerIdController = TextEditingController();
  TextEditingController? customerNameController = TextEditingController();
  TextEditingController? quotationAddressController = TextEditingController();
  TextEditingController? quotationPostalController = TextEditingController();
  TextEditingController? quotationCityController = TextEditingController();
  TextEditingController? quotationContactController = TextEditingController();
  TextEditingController? quotationReferenceController = TextEditingController();
  TextEditingController? quotationDescriptionController =
      TextEditingController();
  TextEditingController? quotationEmailController = TextEditingController();
  TextEditingController? quotationMobileController = TextEditingController();
  TextEditingController? quotationTelController = TextEditingController();

  bool isValid() {
    if (isEmpty(this.customerId)) {
      return false;
    }

    return true;
  }

  void fillFromCustomer(dynamic customer) {
    this.customerId = customer.customerId;
    this.customerRelation = customer.id;

    this.customerIdController!.text = customer.customerId!;
    this.customerNameController!.text = customer.name!;
    this.quotationAddressController!.text = customer.address!;
    this.quotationPostalController!.text = customer.postal!;
    this.quotationCityController!.text = customer.city!;
    this.quotationCountryCode = customer.countryCode;
    this.quotationContactController!.text = customer.contact!;
    this.quotationEmailController!.text = customer.email!;
    this.quotationTelController!.text = customer.tel!;
    this.quotationMobileController!.text = customer.mobile!;
  }

  @override
  Quotation toModel() {
    return Quotation(
      id: id,
      customerId: customerId,
      customerRelation: customerRelation,
      quotationName: customerNameController!.text,
      quotationAddress: quotationAddressController!.text,
      quotationCity: quotationCityController!.text,
      quotationContact: quotationContactController!.text,
      quotationCountryCode: quotationCountryCode,
      quotationEmail: quotationEmailController!.text,
      quotationMobile: quotationMobileController!.text,
      quotationPostal: quotationPostalController!.text,
      quotationTel: quotationTelController!.text,
      description: quotationDescriptionController!.text,
      quotationReference: quotationReferenceController!.text,
      accepted: quotationAccepted,
    );
  }

  factory QuotationFormData.createEmpty() {
    TextEditingController typeAheadControllerCustomer = TextEditingController();

    TextEditingController customerIdController = TextEditingController();
    TextEditingController customerNameController = TextEditingController();
    TextEditingController quotationAddressController = TextEditingController();
    TextEditingController quotationPostalController = TextEditingController();
    TextEditingController quotationCityController = TextEditingController();
    TextEditingController quotationContactController = TextEditingController();
    TextEditingController quotationReferenceController =
        TextEditingController();
    TextEditingController quotationDescriptionController =
        TextEditingController();
    TextEditingController quotationEmailController = TextEditingController();
    TextEditingController quotationMobileController = TextEditingController();
    TextEditingController quotationTelController = TextEditingController();

    return QuotationFormData(
        id: null,
        customerRelation: null,
        customerId: null,
        typeAheadControllerCustomer: typeAheadControllerCustomer,
        customerIdController: customerIdController,
        customerNameController: customerNameController,
        quotationAddressController: quotationAddressController,
        quotationPostalController: quotationPostalController,
        quotationCityController: quotationCityController,
        quotationContactController: quotationContactController,
        quotationReferenceController: quotationReferenceController,
        quotationDescriptionController: quotationDescriptionController,
        quotationEmailController: quotationEmailController,
        quotationMobileController: quotationMobileController,
        quotationTelController: quotationTelController,
        quotationCountryCode: 'NL');
  }

  factory QuotationFormData.createFromModel(Quotation quotation) {
    TextEditingController typeAheadControllerCustomer = TextEditingController();

    TextEditingController customerIdController = TextEditingController();
    customerIdController.text = checkNull(quotation.customerId);
    TextEditingController customerNameController = TextEditingController();
    customerNameController.text = checkNull(quotation.quotationName);
    TextEditingController quotationAddressController = TextEditingController();
    quotationAddressController.text = checkNull(quotation.quotationAddress);
    TextEditingController quotationPostalController = TextEditingController();
    quotationPostalController.text = checkNull(quotation.quotationPostal);
    TextEditingController quotationCityController = TextEditingController();
    quotationCityController.text = checkNull(quotation.quotationCity);
    TextEditingController quotationContactController = TextEditingController();
    quotationContactController.text = checkNull(quotation.quotationContact);
    TextEditingController quotationReferenceController =
        TextEditingController();
    quotationReferenceController.text = checkNull(quotation.quotationReference);
    TextEditingController quotationDescriptionController =
        TextEditingController();
    quotationDescriptionController.text = checkNull(quotation.description);
    TextEditingController quotationEmailController = TextEditingController();
    quotationEmailController.text = checkNull(quotation.quotationEmail);
    TextEditingController quotationMobileController = TextEditingController();
    quotationMobileController.text = checkNull(quotation.quotationMobile);
    TextEditingController quotationTelController = TextEditingController();
    quotationTelController.text = checkNull(quotation.quotationTel);

    return QuotationFormData(
        id: quotation.id,
        customerRelation: quotation.customerRelation,
        customerId: quotation.customerId,
        typeAheadControllerCustomer: typeAheadControllerCustomer,
        customerIdController: customerIdController,
        customerNameController: customerNameController,
        quotationAddressController: quotationAddressController,
        quotationPostalController: quotationPostalController,
        quotationCityController: quotationCityController,
        quotationContactController: quotationContactController,
        quotationReferenceController: quotationReferenceController,
        quotationDescriptionController: quotationDescriptionController,
        quotationEmailController: quotationEmailController,
        quotationMobileController: quotationMobileController,
        quotationTelController: quotationTelController,
        quotationCountryCode: 'NL');
  }

  QuotationFormData({
    this.id,
    this.customerRelation,
    this.customerId,
    this.typeAheadControllerCustomer,
    this.customerIdController,
    this.customerNameController,
    this.quotationAddressController,
    this.quotationPostalController,
    this.quotationCityController,
    this.quotationContactController,
    this.quotationReferenceController,
    this.quotationDescriptionController,
    this.quotationEmailController,
    this.quotationMobileController,
    this.quotationTelController,
    this.quotationCountryCode,
    this.quotationAccepted = false,
  });
}
