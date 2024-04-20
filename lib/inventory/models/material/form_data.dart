import 'package:my24_flutter_core/models/base_models.dart';
import 'models.dart';

class MaterialFormData extends BaseFormData<MaterialModel>  {
  int? id;
  String? identifier;
  String? showName;
  String? name;
  String? nameShort;
  String? unit;
  String? supplier;
  int? supplierRelation;
  String? typeAheadSupplier;

  dynamic getProp(String key) => <String, dynamic>{
    'identifier' : identifier,
    'showName' : showName,
    'nameShort' : nameShort,
    'unit' : unit,
    'supplierRelation' : supplierRelation,
    'supplier': supplier,
    'typeAheadSupplier': typeAheadSupplier
  }[key];

  dynamic setProp(String key, String value) {
    switch (key) {
      case 'identifier': {
        this.identifier = value;
      }
      break;

      case 'name': {
        this.name = value;
      }
      break;

      case 'showName': {
        this.showName = value;
      }
      break;

      case 'nameShort': {
        this.nameShort = value;
      }
      break;

      case 'unit': {
        this.unit = value;
      }
      break;

      case 'supplierRelation': {
        this.supplierRelation = int.parse(value);
      }
      break;

      case 'supplier': {
        this.supplier = value;
      }
      break;

      case 'typeAheadSupplier': {
        this.typeAheadSupplier = value;
      }
      break;

      default:
        {
          throw Exception("unknown field: $key");
        }
    }
  }

  MaterialFormData({
    this.id,
    this.identifier,
    this.name,
    this.nameShort,
    this.showName,
    this.unit,
    this.supplierRelation,
    this.supplier,
    this.typeAheadSupplier
  });

  factory MaterialFormData.createFromModel(MaterialModel material) {
    return MaterialFormData(
      id: material.id,
      identifier: checkNull(material.identifier),
      name: checkNull(material.name),
      nameShort: checkNull(material.nameShort),
      showName: checkNull(material.showName),
      unit: checkNull(material.unit),
      supplierRelation: material.supplierRelation,
      typeAheadSupplier: "",
      supplier: checkNull(material.supplier)
    );
  }

  factory MaterialFormData.createEmpty() {
    return MaterialFormData(
      id: null,
      identifier: "",
      name: "",
      showName: "",
      nameShort: "",
      unit: "",
      supplierRelation: null,
      typeAheadSupplier: "",
      supplier: ""
    );
  }

  MaterialModel toModel() {
    return MaterialModel(
      id: this.id,
      name: this.name,
      nameShort: this.nameShort,
      showName: this.showName,
      unit: this.unit,
      supplierRelation: this.supplierRelation,
      supplier: this.supplier
    );
  }

  bool isValid() {
    if (isEmpty(this.name)) {
      return false;
    }

    return true;
  }
}
