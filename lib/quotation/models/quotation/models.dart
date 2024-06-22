import 'dart:convert';

import 'package:my24_flutter_core/models/base_models.dart';

class Quotation extends BaseModel {
  final int? id;
  final String? quotationId;
  final String? customerId;
  final int? customerRelation;
  final String? quotationName;
  final String? quotationAddress;
  final String? quotationPostal;
  final String? quotationPoBox;
  final String? quotationCity;
  final String? quotationCountryCode;
  final String? quotationEmail;
  final String? quotationTel;
  final String? quotationMobile;
  final String? quotationContact;
  final String? quotationReference;
  final bool? accepted;
  final String? description;
  final String? lastStatusFull;
  final String? created;
  final String? total;
  final String? vat;

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
    this.accepted,
    this.description,
    this.lastStatusFull,
    this.created,
    this.total,
    this.vat,
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
        accepted: parsedJson['accepted'],
        description: parsedJson['description'],
        lastStatusFull: parsedJson['last_status_full'],
        created: parsedJson['created'],
        total: parsedJson['total'],
        vat: parsedJson['vat']);
  }

  @override
  String toJson() {
    final Map<String, dynamic> body = {
      'description': description,
      'customer_id': customerId,
      'customer_relation': customerRelation,
      'quotation_name': quotationName,
      'quotation_address': quotationAddress,
      'quotation_city': quotationCity,
      'quotation_postal': quotationPostal,
      'quotation_country_code': quotationCountryCode,
      'quotation_tel': quotationTel,
      'quotation_mobile': quotationMobile,
      'quotation_email': quotationEmail,
      'quotation_contact': quotationContact,
      'quotation_po_box': quotationPoBox,
      'quotation_reference': quotationReference,
      'accepted': accepted,
    };

    return json.encode(body);
  }
}

class Quotations extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<Quotation>? results;

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

class QuotationPageMetaData {
  final String? submodel;
  final dynamic drawer;
  final String? memberPicture;

  QuotationPageMetaData({
    required this.submodel,
    required this.drawer,
    required this.memberPicture,
  });
}
