import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/inventory/models/models.dart';

class InventoryApi with ApiMixin {
  // default and setable for tests
  http.Client _httpClient = new http.Client();

  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Utils localUtils = utils;
  String _typeAheadToken;

  Future<StockLocations> fetchLocations() async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if(newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/inventory/stock-location/');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      return StockLocations.fromJson(json.decode(response.body));
    }

    throw Exception('assigned_orders.materials.exception_fetch_locations'.tr());
  }

  Future<List<LocationMaterialInventory>> searchLocationProducts(int locationPk, String query) async {
    SlidingToken newToken = await localUtils.refreshSlidingToken();

    if (newToken == null) {
      throw Exception('generic.token_expired'.tr());
    }

    final url = await getUrl('/inventory/inventory-materials-for-location/?location=$locationPk&q=$query');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      var list = parsedJson as List;
      List<LocationMaterialInventory> results = list.map((i) => LocationMaterialInventory.fromJson(i)).toList();

      return results;
    }

    return [];
  }

  Future<int> getInventoryForMaterialLocation(int materialId, int locationId) async {
    // check if we're cached
    if (_typeAheadToken == null) {
      SlidingToken newToken = await localUtils.refreshSlidingToken();

      if(newToken == null) {
        throw Exception('generic.token_expired'.tr());
      }

      _typeAheadToken = newToken.token;
    }

    final url = await getUrl('/inventory/inventory-for-material-location/?location=$locationId&material=$materialId');
    final response = await _httpClient.get(
        Uri.parse(url),
        headers: localUtils.getHeaders(_typeAheadToken)
    );

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      print(parsedJson);

      return parsedJson['inventory'];
    }

    throw Exception('error fetching inventory');
  }

  Future <List<InventoryMaterialTypeAheadModel>> materialTypeAhead(String query) async {
    // check if we're cached
    if (_typeAheadToken == null) {
      SlidingToken newToken = await localUtils.refreshSlidingToken();

      if(newToken == null) {
        throw Exception('generic.token_expired'.tr());
      }

      _typeAheadToken = newToken.token;
    }

    final url = await getUrl('/inventory/material/autocomplete/?q=' + query);
    final response = await _httpClient.get(
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

InventoryApi inventoryApi = InventoryApi();
