import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class InfolineApi extends BaseCrud<Infoline, Infolines> {
  final String basePath = "/order/infoline";

  @override
  Infoline fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Infoline.fromJson(parsedJson!);
  }

  @override
  Infolines fromJsonList(Map<String, dynamic>? parsedJson) {
    return Infolines.fromJson(parsedJson!);
  }
}
