import 'package:my24app/core/api/base_crud.dart';
import 'models.dart';

class ChapterApi extends BaseCrud<Chapter, Chapters> {
  final String basePath = "/quotation/chapter";

  @override
  Chapter fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Chapter.fromJson(parsedJson!);
  }

  @override
  Chapters fromJsonList(Map<String, dynamic>? parsedJson) {
    return Chapters.fromJson(parsedJson!);
  }
}
