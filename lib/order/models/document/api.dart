import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class OrderDocumentApi extends BaseCrud<OrderDocument, OrderDocuments> {
  final String basePath = "/order/document";

  @override
  OrderDocument fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return OrderDocument.fromJson(parsedJson!);
  }

  @override
  OrderDocuments fromJsonList(Map<String, dynamic>? parsedJson) {
    return OrderDocuments.fromJson(parsedJson!);
  }

}
