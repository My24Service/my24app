import 'package:my24app/core/api/base_crud.dart';
import 'models.dart';

class ProjectApi extends BaseCrud<Project, Projects> {
  final String basePath = "/company/project";

  @override
  Project fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Project.fromJson(parsedJson!);
  }

  @override
  Projects fromJsonList(Map<String, dynamic>? parsedJson) {
    return Projects.fromJson(parsedJson!);
  }

  Future<Projects> fetchProjectsForSelect() async {
    return super.list(
        basePathAddition: 'list_for_select/');
  }
}
