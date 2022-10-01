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
  final bool preliminary;
  final bool accepted;
  final String description;
  final String signatureEngineer;
  final String signatureNameEngineer;
  final String signatureCustomer;
  final String signatureNameCustomer;
  final String lastStatusFull;
  final String created;
  List<QuotationPart> parts;

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
    this.preliminary,
    this.accepted,
    this.description,
    this.signatureEngineer,
    this.signatureNameEngineer,
    this.signatureCustomer,
    this.signatureNameCustomer,
    this.lastStatusFull,
    this.created,
    this.parts,
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
      preliminary: parsedJson['preliminary'],
      accepted: parsedJson['accepted'],
      description: parsedJson['description'],
      signatureEngineer: parsedJson['signature_engineer'],
      signatureNameEngineer: parsedJson['signature_name_engineer'],
      signatureCustomer: parsedJson['signature_customer'],
      signatureNameCustomer: parsedJson['signature_name_customer'],
      lastStatusFull: parsedJson['last_status_full'],
      created: parsedJson['created'],
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
  final int quotatonPartId;
  final String oldProduct;
  final String newProductName;
  final String newProductIdentifier;
  final int newProductRelation;
  final double amount;
  final String location;
  final String info;

  QuotationPartLine({
    this.id,
    this.quotatonPartId,
    this.oldProduct,
    this.newProductName,
    this.newProductIdentifier,
    this.newProductRelation,
    this.amount,
    this.location,
    this.info,
  });

  factory QuotationPartLine.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationPartLine(
      id: parsedJson['id'],
      quotatonPartId: parsedJson['quotation_part_id'],
      oldProduct: parsedJson['old_product'],
      newProductName: parsedJson['new_product_name'],
      newProductIdentifier: parsedJson['new_product_identifier'],
      newProductRelation: parsedJson['new_product_relation'],
      amount: parsedJson['amount'],
      location: parsedJson['location'],
      info: parsedJson['info'],
    );
  }
}

class QuotationPartLines {
  final int count;
  final String next;
  final String previous;
  final List<QuotationPartLine> results;

  QuotationPartLines({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory QuotationPartLines.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<QuotationPartLine> results = list.map((i) => QuotationPartLine.fromJson(i)).toList();

    return QuotationPartLines(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}


class QuotationPartImage {
  final int id;
  final int quotatonPartId;
  final String image;
  final String thumbnail;
  final String description;
  String imageUrl;
  String thumbnailUrl;

  QuotationPartImage({
    this.id,
    this.quotatonPartId,
    this.image,
    this.thumbnail,
    this.description,
    this.imageUrl,
    this.thumbnailUrl,
  });

  factory QuotationPartImage.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationPartImage(
      id: parsedJson['id'],
      quotatonPartId: parsedJson['quotation_part_id'],
      image: parsedJson['image'],
      description: parsedJson['description'],
      imageUrl: parsedJson['image_url'],
      thumbnailUrl: parsedJson['thumbnail_url'],
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
  final int quotationId;
  final String description;
  List<QuotationPartLine> lines;
  List<QuotationPartImage> images;

  QuotationPart({
    this.id,
    this.quotationId,
    this.description,
    this.lines,
    this.images,
  });

  factory QuotationPart.fromJson(Map<String, dynamic> parsedJson) {
    return QuotationPart(
      id: parsedJson['id'],
      quotationId: parsedJson['quotation_id'],
      description: parsedJson['description'],
    );
  }
}

class QuotationParts {
  final int count;
  final String next;
  final String previous;
  final List<QuotationPart> results;

  QuotationParts({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory QuotationParts.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<QuotationPart> results = list.map((i) => QuotationPart.fromJson(i)).toList();

    return QuotationParts(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}
