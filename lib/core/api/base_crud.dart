import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/core/models/base_models.dart';


abstract class BaseCrud<T extends BaseModel, U extends BaseModelPagination> with ApiMixin {
  final String basePath = null;
  http.Client _httpClient = new http.Client();

  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Utils localUtils = utils;

  U fromJsonList(Map<String, dynamic> parsedJson);
  T fromJsonDetail(Map<String, dynamic> parsedJson);

  Future<U> list({Map<String, dynamic> filters}) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    List<String> args = [];
    if (filters != null) {
      filters.forEach((k, v) => args.add("$k=$v"));
    }

    String url = await getUrl('$basePath/');
    if (args.length > 0) {
      url = "$url?${args.join('&')}";
    }

    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return fromJsonList(json.decode(response.body));
    }

    final String errorMsg = 'generic.exception_fetch'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<T> detail(int pk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('$basePath/$pk/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return fromJsonDetail(json.decode(response.body));
    }

    final String errorMsg = 'generic.exception_fetch'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<T> insert(BaseModel model) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('$basePath/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final response = await _httpClient.post(
      Uri.parse(url),
      body: model.toJson(),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return fromJsonDetail(json.decode(response.body));
    }

    final String errorMsg = 'generic.exception_insert'.tr();
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<T> update(int pk, BaseModel model) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('$basePath/$pk/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final response = await _httpClient.patch(
      Uri.parse(url),
      body: model.toJson(),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return fromJsonDetail(json.decode(response.body));
    }

    final String errorMsg = 'generic.exception_update'.tr();
    String msg = "$errorMsg (${response.body})";
    throw Exception(msg);
  }

  Future<bool> delete(int pk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('$basePath/$pk/');
    final response = await _httpClient.delete(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    final String errorMsg = 'generic.exception_delete'.tr();
    String msg = "$errorMsg (${response.body})";
    throw Exception(msg);
  }

}
