import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/core/models/base_models.dart';

import '../i18n_mixin.dart';


abstract class BaseCrud<T extends BaseModel, U extends BaseModelPagination> with ApiMixin {
  final String basePath = null;
  http.Client httpClient = new http.Client();

  Utils localUtils = utils;

  U fromJsonList(Map<String, dynamic> parsedJson);
  T fromJsonDetail(Map<String, dynamic> parsedJson);

  Future<U> list({Map<String, dynamic> filters, String basePathAddition}) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception(getTranslationTr('generic.token_expired', null));
    }

    // List<String> args = ["page_size=5"];
    List<String> args = [];
    if (filters != null) {
      for (String key in filters.keys) {
        if (filters[key] != null) {
          args.add("$key=${filters[key]}");
        }
      }
    }

    String url = await getUrl('$basePath');
    if (basePathAddition != null) {
      url = "$url/$basePathAddition";
    }

    if (args.length > 0) {
      url = "$url/?${args.join('&')}";
    }
    // print(url);

    final response = await httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      // print(response.body);
      return fromJsonList(json.decode(response.body));
    }

    final String errorMsg = getTranslationTr('generic.exception_fetch', null);
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<T> detail(int pk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception(getTranslationTr('generic.token_expired', null));
    }

    final url = await getUrl('$basePath/$pk/');
    final response = await httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return fromJsonDetail(json.decode(response.body));
    }

    final String errorMsg = getTranslationTr('generic.exception_fetch_detail', null);
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<T> insert(BaseModel model) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception(getTranslationTr('generic.token_expired', null));
    }

    final url = await getUrl('$basePath/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final response = await httpClient.post(
      Uri.parse(url),
      body: model.toJson(),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return fromJsonDetail(json.decode(response.body));
    }

    final String errorMsg = getTranslationTr('generic.exception_insert', null);
    String msg = "$errorMsg (${response.body})";

    throw Exception(msg);
  }

  Future<T> update(int pk, BaseModel model) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception(getTranslationTr('generic.token_expired', null));
    }

    final url = await getUrl('$basePath/$pk/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(localUtils.getHeaders(newToken.token));

    final response = await httpClient.patch(
      Uri.parse(url),
      body: model.toJson(),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return fromJsonDetail(json.decode(response.body));
    }

    final String errorMsg = getTranslationTr('generic.exception_update', null);
    String msg = "$errorMsg (${response.body})";
    throw Exception(msg);
  }

  Future<bool> delete(int pk) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception(getTranslationTr('generic.token_expired', null));
    }

    final url = await getUrl('$basePath/$pk/');
    final response = await httpClient.delete(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    final String errorMsg = getTranslationTr('generic.exception_delete', null);
    String msg = "$errorMsg (${response.body})";
    throw Exception(msg);
  }

}
