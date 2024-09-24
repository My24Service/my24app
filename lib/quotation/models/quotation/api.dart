import 'dart:convert';

import 'package:my24_flutter_core/api/base_crud.dart';
import '../quotation_line/models.dart';
import 'models.dart';

class QuotationApi extends BaseCrud<Quotation, Quotations> {
  final String basePath = "/quotation/quotation";

  @override
  Quotation fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Quotation.fromJson(parsedJson!);
  }

  @override
  Quotations fromJsonList(Map<String, dynamic>? parsedJson) {
    return Quotations.fromJson(parsedJson!);
  }

  Future<Quotations> fetchPreliminaryQuotations(
      {Map<String, dynamic>? filters}) async {
    return super.list(basePathAddition: 'preliminary/', filters: filters);
  }

  Future<Quotations> fetchUnAcceptedQuotations() async {
    return super.list(basePathAddition: 'not_accepted/');
  }

  Future<List<QuotationLineMaterial>> fetchQuotationMaterials(int pk) async {
    final String responseBody = await getListResponseBody(
        basePathAddition: '$pk/get_materials_for_app/'
    );
    final list = json.decode(responseBody) as List;
    List<QuotationLineMaterial> results = list.map((i) => QuotationLineMaterial.fromJson(i)).toList();
    return results;
  }
}
