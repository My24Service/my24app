import 'dart:convert';

import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class AssignedOrderMaterialApi extends BaseCrud<AssignedOrderMaterial, AssignedOrderMaterials> {
  final String basePath = "/mobile/assignedordermaterial";

  @override
  AssignedOrderMaterial fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return AssignedOrderMaterial.fromJson(parsedJson!);
  }

  @override
  AssignedOrderMaterials fromJsonList(Map<String, dynamic>? parsedJson) {
    return AssignedOrderMaterials.fromJson(parsedJson!);
  }

  Future<List<AssignedOrderMaterialQuotation>> quotationMaterials(int quotationId) async {
    final String responseBody = await getListResponseBody(
      basePathAddition: 'quotation/',
      filters: {'quotation': quotationId}
    );
    final list = json.decode(responseBody) as List;
    List<AssignedOrderMaterialQuotation> results = list.map((i) => AssignedOrderMaterialQuotation.fromJson(i)).toList();
    return results;
  }
}
