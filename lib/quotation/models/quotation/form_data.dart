import 'package:flutter/cupertino.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'models.dart';

class QuotationFormData extends BaseFormData<Quotation> {
  TextEditingController? typeAheadControllerCustomer = TextEditingController();

  int? id;
  int? branch;
  int? customerRelation;
  String? searchCustomerText;
  String? customerId;
  String? quotationCountryCode = 'NL';
  bool quotationAccepted = false;
  String? customerName;
  String? quotationAddress;
  String? quotationPostal;
  String? quotationCity;
  String? quotationContact;
  String? quotationReference;
  String? quotationDescription;
  String? quotationEmail;
  String? quotationMobile;
  String? quotationTel;

  bool isValid() {
    if (isEmpty(this.customerId)) {
      return false;
    }

    return true;
  }

  void fillFromCustomer(dynamic customer) {
    this.customerId = customer.customerId;
    this.customerRelation = customer.id;
    this.quotationCountryCode = customer.countryCode;
  }

  dynamic getProp(String key) => <String, dynamic>{
        'searchCustomerText': searchCustomerText,
        'customerId': customerId,
        'customerName': customerName,
        'quotationAddress': quotationAddress,
        'quotationPostal': quotationPostal,
        'quotationCity': quotationCity,
        'quotationContact': quotationContact,
        'quotationReference': quotationReference,
        'quotationDescription': quotationDescription,
        'quotationEmail': quotationEmail,
        'quotationMobile': quotationMobile,
        'quotationTel': quotationTel,
      }[key];

  dynamic setProp(String key, String value) {
    switch (key) {
      case 'searchCustomerText':
        this.searchCustomerText = value;
        break;
      case 'customerId':
        this.customerId = value;
        break;
      case 'customerName':
        this.customerName = value;
        break;
      case 'quotationAddress':
        this.quotationAddress = value;
        break;
      case 'quotationPostal':
        this.quotationPostal = value;
        break;
      case 'quotationCity':
        this.quotationCity = value;
        break;
      case 'quotationContact':
        this.quotationContact = value;
        break;
      case 'quotationReference':
        this.quotationReference = value;
        break;
      case 'quotationDescription':
        this.quotationDescription = value;
        break;
      case 'quotationEmail':
        this.quotationEmail = value;
        break;
      case 'quotationMobile':
        this.quotationMobile = value;
        break;
      case 'quotationTel':
        this.quotationTel = value;
        break;
      default:
        throw Exception("unknown field: $key");
    }
  }

  @override
  Quotation toModel() {
    return Quotation(
      id: id,
      customerId: customerId,
      customerRelation: customerRelation,
      quotationName: customerName,
      quotationAddress: quotationAddress,
      quotationCity: quotationCity,
      quotationContact: quotationContact,
      quotationCountryCode: quotationCountryCode,
      quotationEmail: quotationEmail,
      quotationMobile: quotationMobile,
      quotationPostal: quotationPostal,
      quotationTel: quotationTel,
      description: quotationDescription,
      quotationReference: quotationReference,
      accepted: quotationAccepted,
    );
  }

  factory QuotationFormData.createEmpty() {
    return QuotationFormData(
        id: null,
        customerRelation: null,
        customerId: null,
        searchCustomerText: null,
        customerName: null,
        quotationAddress: null,
        quotationPostal: null,
        quotationCity: null,
        quotationContact: null,
        quotationReference: null,
        quotationDescription: null,
        quotationEmail: null,
        quotationMobile: null,
        quotationTel: null,
        quotationCountryCode: 'NL');
  }

  factory QuotationFormData.createFromModel(Quotation quotation) {
    return QuotationFormData(
        id: quotation.id,
        customerRelation: quotation.customerRelation,
        customerId: quotation.customerId,
        customerName: quotation.quotationName,
        quotationAddress: quotation.quotationAddress,
        quotationCity: quotation.quotationCity,
        quotationContact: quotation.quotationContact,
        quotationEmail: quotation.quotationEmail,
        quotationMobile: quotation.quotationMobile,
        quotationPostal: quotation.quotationPostal,
        quotationTel: quotation.quotationTel,
        quotationDescription: quotation.description,
        quotationReference: quotation.quotationReference,
        quotationAccepted: quotation.accepted!,
        quotationCountryCode: 'NL');
  }

  QuotationFormData({
    this.id,
    this.customerRelation,
    this.customerId,
    this.searchCustomerText,
    this.customerName,
    this.quotationAddress,
    this.quotationPostal,
    this.quotationCity,
    this.quotationContact,
    this.quotationReference,
    this.quotationDescription,
    this.quotationEmail,
    this.quotationMobile,
    this.quotationTel,
    this.quotationCountryCode,
    this.quotationAccepted = false,
  });
}
