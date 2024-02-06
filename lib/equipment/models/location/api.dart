import 'dart:async';
import 'dart:convert';

import 'package:my24_flutter_core/api/base_crud.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'models.dart';

class EquipmentLocationApi extends BaseCrud<EquipmentLocation, EquipmentLocations> {
  final String basePath = "/equipment/location";
  String? _typeAheadToken;

  @override
  EquipmentLocation fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return EquipmentLocation.fromJson(parsedJson!);
  }

  @override
  EquipmentLocations fromJsonList(Map<String, dynamic>? parsedJson) {
    return EquipmentLocations.fromJson(parsedJson!);
  }

  Future<List<EquipmentLocation>> fetchLocationsForSelect() async {
    final String response = await super.getListResponseBody(
        basePathAddition: 'list_for_select/');

    return EquipmentLocation.getListFromResponse(response);
  }

  Future<EquipmentLocationCreateQuickResponse> createQuickCustomer(
      EquipmentLocationCreateQuickCustomer location) async {
    final Map body = location.toMap();
    return await createQuick(body);
  }

  Future<EquipmentLocationCreateQuickResponse> createQuickBranch(
      EquipmentLocationCreateQuickBranch location) async {
    final Map body = location.toMap();
    return await createQuick(body);
  }

  Future<EquipmentLocationCreateQuickResponse> createQuick(Map body) async {
    String basePathAddition = 'create_quick/';
    final Map result = await (super.insertCustom(body, basePathAddition, returnTypeBool: false) as FutureOr<Map<dynamic, dynamic>>);
    return EquipmentLocationCreateQuickResponse.fromJson(result as Map<String, dynamic>);
  }

  Future <List<EquipmentLocationTypeAheadModel>> locationTypeAhead(String query, int? branch) async {
    if (_typeAheadToken == null) {
      SlidingToken newToken = await getNewToken();

      _typeAheadToken = newToken.token;
    }

    final url = branch == null ? await getUrl('/equipment/location/autocomplete/?q=' + query) : await getUrl('/equipment/location/autocomplete/?q=$query&branch=$branch');
    final response = await httpClient.get(
        Uri.parse(url),
        headers: getHeaders(_typeAheadToken)
    );

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      var list = parsedJson as List;
      List<EquipmentLocationTypeAheadModel> results = list.map(
              (i) => EquipmentLocationTypeAheadModel.fromJson(i)
      ).toList();

      return results;
    }

    return [];
  }
}
