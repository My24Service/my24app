import 'dart:convert';

import 'package:my24app/core/api/base_crud.dart';
import 'package:my24app/core/models/models.dart';
import '../../core/i18n_mixin.dart';
import 'models.dart';

class InventoryApi extends BaseCrud<StockLocation, StockLocations> {
  final String basePath = "/inventory/stock-location/";
  String _typeAheadToken;

  @override
  StockLocation fromJsonDetail(Map<String, dynamic> parsedJson) {
    return StockLocation.fromJson(parsedJson);
  }

  @override
  StockLocations fromJsonList(Map<String, dynamic> parsedJson) {
    return StockLocations.fromJson(parsedJson);
  }

  Future<List<LocationMaterialInventory>> searchLocationProducts(int locationPk, String query) async {
    SlidingToken newToken = await getNewToken();

    final url = await getUrl('/inventory/inventory-materials-for-location/?location=$locationPk&q=$query');
    final response = await httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      var list = parsedJson as List;
      List<LocationMaterialInventory> results = list.map((i) => LocationMaterialInventory.fromJson(i)).toList();

      return results;
    }

    if (response.statusCode >= 500) {
      final String errorMsg = getTranslationTr('generic.exception_fetch', null);
      String msg = "$errorMsg (${response.body})";

      throw Exception(msg);
    }

    return [];
  }

  Future <List<InventoryMaterialTypeAheadModel>> materialTypeAhead(String query) async {
    if (_typeAheadToken == null) {
      SlidingToken newToken = await getNewToken();

      _typeAheadToken = newToken.token;
    }

    final url = await getUrl('/inventory/material/autocomplete/?q=' + query);
    final response = await httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(_typeAheadToken)
    );

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      var list = parsedJson as List;
      List<InventoryMaterialTypeAheadModel> results = list.map((i) => InventoryMaterialTypeAheadModel.fromJson(i)).toList();

      return results;
    }

    return [];
  }
}
