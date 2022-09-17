import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/quotation/models/models.dart';

class QuotationApi with ApiMixin {
  // default and setable for tests
  http.Client _httpClient = new http.Client();

  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Utils localUtils = utils;

  Future<Quotations> fetchQuotations({ query='', page=1}) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    String url = await getUrl('/quotation/quotation/');
    List<String> args = [];

    if (query != null && query != '') {
      args.add('q=$query');
    }

    if (page != null && page != 1) {
      args.add('page=$page');
    }

    if (args.length > 0) {
      url = '$url?' + args.join('&');
    }

    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Quotations.fromJson(json.decode(response.body));
    }

    throw Exception('quotations.exception_fetch'.tr());
  }

  Future<Quotation> fetchQuotation(int quotationid) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    String url = await getUrl('/quotation/quotation/$quotationid/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Quotation.fromJson(json.decode(response.body));
    }

    throw Exception('quotations.exception_fetch'.tr());
  }

  Future<Quotations> fetchUncceptedQuotations() async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/quotation/quotation/get_not_accepted/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return Quotations.fromJson(json.decode(response.body));
    }

    throw Exception('quotations.exception_fetch'.tr());
  }

  Future<Quotation> insertQuotation(Quotation quotation) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/quotation/quotation/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    Map body = {
      'customer_id': quotation.customerId,
      'customer_relation': quotation.customerRelation,
      'quotation_name': quotation.quotationName,
      'quotation_address': quotation.quotationAddress,
      'quotation_postal': quotation.quotationPostal,
      'quotation_city': quotation.quotationCity,
      'quotation_country_code': quotation.quotationCountryCode,
      'quotation_email': quotation.quotationEmail,
      'quotation_tel': quotation.quotationTel,
      'quotation_mobile': quotation.quotationMobile,
      'quotation_contact': quotation.quotationContact,
      'quotation_reference': quotation.quotationReference,
      'description': quotation.description,
      'quotation_images': [],
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return Quotation.fromJson(json.decode(response.body));
    }

    return null;
  }

  Future<bool> acceptQuotation(int quotationPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/quotation/quotation/$quotationPk/set_quotation_accepted/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {};

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return null;
  }

  Future<bool> deleteQuotation(int quotationPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/quotation/quotation/$quotationPk/');
    final response = await _httpClient.delete(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    return false;
  }

  // images
  Future<QuotationPartImages> fetchQuotationPartImages(int quotationPartPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/quotation/quotation-image/?quotation_part=$quotationPartPk');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return QuotationPartImages.fromJson(json.decode(response.body));
    }

    throw Exception('quotations.images.exception_fetch'.tr());
  }

  Future<QuotationPartImage> insertQuotationPartImage(QuotationPartImage image, int quotationPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/quotation/quotation-image/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'quotation': quotationPk,
      'image': image.image,
      'description': image.description,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return QuotationPartImage.fromJson(json.decode(response.body));
    }

    return null;
  }

  Future<bool> deleteQuotationImage(int imagePk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/quotation/quotation-image/$imagePk/');
    final response = await _httpClient.delete(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    return false;
  }

}

QuotationApi quotationApi = QuotationApi();
