import 'dart:convert';

class Quotation {
  final int id;
  final String customerId;
  final int customerRelation;
  final String quotationName;
  final String quotationAddress;
  final String quotationPostal;
  final String quotationPoBox;
  final String quotationCity;
  final String quotationCountryCode;
  final String quotationEmail;
  final String quotationTel;
  final String quotationMobile;
  final String quotationContact;
  final String quotationReference;
  final String description;
  final String workHours;
  final String travelTo;
  final String travelBack;
  final int distanceTo;
  final int distanceBack;
  final String signatureEngineer;
  final String signatureNameEngineer;
  final String signatureCustomer;
  final String signatureNameCustomer;
  final String status;
  List<QuotationProduct> quotationProducts;

  Quotation({
    this.id,
    this.customerId,
    this.customerRelation,
    this.quotationName,
    this.quotationAddress,
    this.quotationPostal,
    this.quotationPoBox,
    this.quotationCity,
    this.quotationCountryCode,
    this.quotationEmail,
    this.quotationTel,
    this.quotationMobile,
    this.quotationContact,
    this.quotationReference,
    this.description,
    this.workHours,
    this.travelTo,
    this.travelBack,
    this.distanceTo,
    this.distanceBack,
    this.signatureEngineer,
    this.signatureNameEngineer,
    this.signatureCustomer,
    this.signatureNameCustomer,
    this.status,
    this.quotationProducts,
  });

  factory Quotation.fromJson(Map<String, dynamic> parsedJson) {
    return Quotation(
      id: parsedJson['id'],
      customerId: parsedJson['customer_id'],
      customerRelation: parsedJson['customer_relation'],
      quotationName: parsedJson['quotation_name'],
      quotationAddress: parsedJson['quotation_address'],
      quotationPostal: parsedJson['quotation_postal'],
      quotationPoBox: parsedJson['quotation_po_box'],
      quotationCity: parsedJson['quotation_city'],
      quotationCountryCode: parsedJson['quotation_country_code'],
      quotationEmail: parsedJson['quotation_email'],
      quotationTel: parsedJson['quotation_tel'],
      quotationMobile: parsedJson['quotation_mobile'],
      quotationContact: parsedJson['quotation_contact'],
      quotationReference: parsedJson['quotation_reference'],
      description: parsedJson['description'],
      workHours: parsedJson['work_hours'],
      travelTo: parsedJson['travel_to'],
      travelBack: parsedJson['travel_back'],
      distanceTo: parsedJson['distance_to'],
      distanceBack: parsedJson['distance_back'],
      signatureEngineer: parsedJson['signature_engineer'],
      signatureNameEngineer: parsedJson['signature_name_engineer'],
      signatureCustomer: parsedJson['signature_customer'],
      signatureNameCustomer: parsedJson['signature_name_customer'],
      status: parsedJson['status'],
    );
  }
}

class Quotations {
  final int count;
  final String next;
  final String previous;
  final List<Quotation> results;

  Quotations({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Quotations.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Quotation> results = list.map((i) => Quotation.fromJson(i)).toList();

    return Quotations(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class QuotationProduct {
  final int id;
  final int quotationId;
  final int productId;
  final String productName;
  final String productIdentifier;
  final double amount;
  final String location;

  QuotationProduct({
    this.id,
    this.quotationId,
    this.productId,
    this.productName,
    this.productIdentifier,
    this.amount,
    this.location,
  });

  factory QuotationProduct.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationProduct(
      id: parsedJson['id'],
      productName: parsedJson['name'],
      productIdentifier: parsedJson['identifier'],
    );
  }
}

class QuotationImage {
  final int id;
  final String image;
  final String description;

  QuotationImage({
    this.id,
    this.image,
    this.description,
  });

  factory QuotationImage.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationImage(
      id: parsedJson['id'],
      image: parsedJson['image'],
      description: parsedJson['description'],
    );
  }
}

class QuotationImages {
  final int count;
  final String next;
  final String previous;
  final List<QuotationImage> results;

  QuotationImages({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory QuotationImages.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<QuotationImage> results = list.map((i) => QuotationImage.fromJson(i)).toList();

    return QuotationImages(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}
