import 'package:my24_flutter_core/models/base_models.dart';

class EquipmentPart extends BaseModel {
  final int? id;
  final int? equipment;
  final String? name;

  EquipmentPart({
    this.id,
    this.equipment,
    this.name,
  });

  factory EquipmentPart.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentPart(
      id: parsedJson['id'],
      equipment: parsedJson['equipment'],
      name: parsedJson['name'],
    );
  }

  @override
  String toJson() {
    return '';
  }
}

class EquipmentParts extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<EquipmentPart>? results;

  EquipmentParts({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory EquipmentParts.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<EquipmentPart> results = list.map((i) => EquipmentPart.fromJson(i)).toList();

    return EquipmentParts(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}
