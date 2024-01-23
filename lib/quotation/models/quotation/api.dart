import 'package:my24app/core/api/base_crud.dart';
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
}
