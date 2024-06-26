import 'dart:convert';

import 'package:my24_flutter_core/api/base_crud.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import './models.dart';

// TODO clean this up into directory
class LocationApi extends BaseCrud<StockLocation, StockLocations> {
  final String basePath = "/inventory/stock-location";

  @override
  StockLocation fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return StockLocation.fromJson(parsedJson!);
  }

  @override
  StockLocations fromJsonList(Map<String, dynamic>? parsedJson) {
    return StockLocations.fromJson(parsedJson!);
  }

  Future<List<LocationMaterialInventory>> searchLocationProducts(int? locationPk, String query) async {
    SlidingToken newToken = await getNewToken();

    final url = await getUrl('/inventory/inventory-materials-for-location/?location=$locationPk&q=$query');
    final response = await httpClient.get(
        Uri.parse(url),
        headers: getHeaders(newToken.token)
    );

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      var list = parsedJson as List;
      List<LocationMaterialInventory> results = list.map((i) => LocationMaterialInventory.fromJson(i)).toList();

      return results;
    }

    if (response.statusCode >= 500) {
      final String errorMsg = My24i18n.tr('generic.exception_fetch');
      String msg = "$errorMsg (${response.body})";

      throw Exception(msg);
    }

    return [];
  }

}
