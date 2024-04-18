import 'dart:convert';

import 'package:my24_flutter_core/api/base_crud.dart';

import 'models.dart';

class MaterialApi extends BaseCrud<Material, Materials> {
  final String basePath = "/inventory/material";

  @override
  Material fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Material.fromJson(parsedJson!);
  }

  @override
  Materials fromJsonList(Map<String, dynamic>? parsedJson) {
    return Materials.fromJson(parsedJson!);
  }

  Future <List<MaterialTypeAheadModel>> typeAhead(String query) async {
    Map<String, dynamic> filters = {'q': query};
    final String responseBody = await getListResponseBody(
        filters: filters, basePathAddition: 'autocomplete');
    var parsedJson = json.decode(responseBody);
    var list = parsedJson as List;
    List<MaterialTypeAheadModel> results = list.map((i) =>
        MaterialTypeAheadModel.fromJson(i)).toList();

    return results;
  }
}
