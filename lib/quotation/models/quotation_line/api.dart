import 'package:my24app/core/api/base_crud.dart';
import 'models.dart';

class QuotationLineApi extends BaseCrud<QuotationLine, QuotationLines> {
  final String basePath = "/quotation/quotation-line";

  @override
  QuotationLine fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return QuotationLine.fromJson(parsedJson!);
  }

  @override
  QuotationLines fromJsonList(Map<String, dynamic>? parsedJson) {
    return QuotationLines.fromJson(parsedJson!);
  }
}
