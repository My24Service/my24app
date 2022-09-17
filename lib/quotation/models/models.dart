class Quotation {
  final int id;
  final String quotationId;
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
  final String signatureEngineer;
  final String signatureNameEngineer;
  final String signatureCustomer;
  final String signatureNameCustomer;
  final String lastStatusFull;
  final String created;
  final bool preliminary;

  Quotation({
    this.id,
    this.quotationId,
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
    this.signatureEngineer,
    this.signatureNameEngineer,
    this.signatureCustomer,
    this.signatureNameCustomer,
    this.lastStatusFull,
    this.created,
    this.preliminary,
  });

  factory Quotation.fromJson(Map<String, dynamic> parsedJson) {
    return Quotation(
      id: parsedJson['id'],
      customerId: parsedJson['customer_id'],
      quotationId: parsedJson['quotation_id'],
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
      signatureEngineer: parsedJson['signature_engineer'],
      signatureNameEngineer: parsedJson['signature_name_engineer'],
      signatureCustomer: parsedJson['signature_customer'],
      signatureNameCustomer: parsedJson['signature_name_customer'],
      lastStatusFull: parsedJson['last_status_full'],
      created: parsedJson['created'],
      preliminary: parsedJson['preliminary'],
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

class QuotationPartLine {
  final int id;
  final int partId;
  final String oldProductName;
  final int productId;
  final String productName;
  final String productIdentifier;
  final double amount;
  final String location;

  QuotationPartLine({
    this.id,
    this.partId,
    this.oldProductName,
    this.productId,
    this.productName,
    this.productIdentifier,
    this.amount,
    this.location,
  });

  factory QuotationPartLine.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationPartLine(
      id: parsedJson['id'],
      partId: parsedJson['quotation_part_id'],
      productName: parsedJson['name'],
      productIdentifier: parsedJson['identifier'],
    );
  }
}

class QuotationPartImage {
  final int id;
  final int partId;
  final String image;
  final String description;

  QuotationPartImage({
    this.id,
    this.partId,
    this.image,
    this.description,
  });

  factory QuotationPartImage.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationPartImage(
      id: parsedJson['id'],
      partId: parsedJson['quotation_part_id'],
      image: parsedJson['image'],
      description: parsedJson['description'],
    );
  }
}

class QuotationPartImages {
  final int count;
  final String next;
  final String previous;
  final List<QuotationPartImage> results;

  QuotationPartImages({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory QuotationPartImages.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<QuotationPartImage> results = list.map((i) => QuotationPartImage.fromJson(i)).toList();

    return QuotationPartImages(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class QuotationPart {
  final int id;
  final String description;
  final List<QuotationPartLine> lines;
  final List<QuotationPartImage> images;

  QuotationPart({
    this.id,
    this.description,
    this.lines,
    this.images,
  });

  factory QuotationPart.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationPart(
      id: parsedJson['id'],
      description: parsedJson['description'],
    );
  }
}

