import 'dart:async';
import 'dart:convert';

import 'package:my24_flutter_core/api/base_crud.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'models.dart';

class EquipmentApi extends BaseCrud<Equipment, EquipmentPaginated> {
  final String basePath = "/equipment/equipment";
  String? _typeAheadToken;

  @override
  Equipment fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Equipment.fromJson(parsedJson!);
  }

  @override
  EquipmentPaginated fromJsonList(Map<String, dynamic>? parsedJson) {
    return EquipmentPaginated.fromJson(parsedJson!);
  }

  Future<EquipmentCreateQuickResponse> createQuickCustomer(EquipmentCreateQuickCustomer equipment) async {
    final Map body = equipment.toMap();
    return await createQuick(body);
  }

  Future<EquipmentCreateQuickResponse> createQuickBranch(EquipmentCreateQuickBranch equipment) async {
    final Map body = equipment.toMap();
    return await createQuick(body);
  }

  Future<EquipmentCreateQuickResponse> createQuick(Map body) async {
    String basePathAddition = 'create_quick/';
    final Map result = await (super.insertCustom(body, basePathAddition, returnTypeBool: false) as FutureOr<Map<dynamic, dynamic>>);
    return EquipmentCreateQuickResponse.fromJson(result as Map<String, dynamic>);
  }

  Future <List<EquipmentTypeAheadModel>> equipmentTypeAhead(String query, int? branch) async {
    if (_typeAheadToken == null) {
      SlidingToken newToken = await getNewToken();

      _typeAheadToken = newToken.token;
    }

    final url = branch == null ? await getUrl('/equipment/equipment/autocomplete/?q=' + query) : await getUrl('/equipment/equipment/autocomplete/?q=$query&branch=$branch');
    final response = await httpClient.get(
        Uri.parse(url),
        headers: getHeaders(_typeAheadToken)
    );

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      var list = parsedJson as List;
      List<EquipmentTypeAheadModel> results = list.map((i) => EquipmentTypeAheadModel.fromJson(i)).toList();

      return results;
    }

    return [];
  }
}
