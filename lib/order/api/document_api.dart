import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/models/models.dart';

class DocumentApi with ApiMixin {
  // default and setable for tests
  http.Client _httpClient = new http.Client();
  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Utils localUtils = utils;

  Future<bool> deleteOrderDocument(int pk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/document/$pk/');
    final response = await _httpClient.delete(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    return false;
  }

  Future<OrderDocuments> fetchOrderDocuments(int orderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/document/?order=$orderPk');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return OrderDocuments.fromJson(json.decode(response.body));
    }

    throw Exception('orders.documents.exception_fetch'.tr());
  }

  Future<OrderDocument> insertOrderDocument(OrderDocument document, int orderPk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/order/document/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final Map body = {
      'order': orderPk,
      'name': document.name,
      'description': document.description,
      'file': document.file,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return OrderDocument.fromJson(json.decode(response.body));
    }

    return null;
  }
}

DocumentApi documentApi = DocumentApi();
