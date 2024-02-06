import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class DocumentApi extends BaseCrud<AssignedOrderDocument, AssignedOrderDocuments> {
  final String basePath = "/mobile/assignedorderdocument";

  @override
  AssignedOrderDocument fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return AssignedOrderDocument.fromJson(parsedJson!);
  }

  @override
  AssignedOrderDocuments fromJsonList(Map<String, dynamic>? parsedJson) {
    return AssignedOrderDocuments.fromJson(parsedJson!);
  }
}
