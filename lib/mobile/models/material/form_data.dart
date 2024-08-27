import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24app/quotation/models/quotation_line/models.dart';
import 'models.dart';

class AssignedOrderMaterialFormData extends BaseFormData<AssignedOrderMaterial>  {
  int? id;
  int? assignedOrderId;
  int? material;
  int? location;
  bool? stockMaterialFound;
  List<QuotationLineMaterial>? quotationMaterials;

  String? name;
  String? identifier;
  String? amount;
  String? typeAheadStock;
  String? typeAheadAll;

  dynamic getProp(String key) => <String, dynamic>{
    'name' : name,
    'identifier' : identifier,
    'amount' : amount,
    'typeAheadStock' : typeAheadStock,
    'typeAheadAll' : typeAheadAll,
  }[key];

  dynamic setProp(String key, String value) {
    switch (key) {
      case 'name': {
        this.name = value;
      }
      break;
      case 'identifier': {
        this.identifier = value;
      }
      break;
      case 'amount': {
        this.amount = value;
      }
      break;
      case 'typeAheadStock': {
        this.typeAheadStock = value;
      }
      break;
      case 'typeAheadAll': {
        this.typeAheadAll = value;
      }
      break;

      default:
        {
          throw Exception("unknown field: $key");
        }
    }
  }

  AssignedOrderMaterialFormData({
    this.id,
    this.assignedOrderId,
    this.material,
    this.location,
    this.stockMaterialFound,

    this.name,
    this.amount,
    this.identifier,
    this.typeAheadAll,
    this.typeAheadStock,
    this.quotationMaterials
  });

  factory AssignedOrderMaterialFormData.createFromModel(AssignedOrderMaterial material) {
    return AssignedOrderMaterialFormData(
      id: material.id,
      assignedOrderId: material.assignedOrderId,
      material: material.material,
      location: material.location,
      stockMaterialFound: true,

      name: checkNull(material.materialName),
      identifier: checkNull(material.materialIdentifier),
      amount: "${material.amount!.round()}",
      typeAheadStock: "",
      typeAheadAll: "",
    );
  }

  factory AssignedOrderMaterialFormData.createEmpty(int? assignedOrderId) {
    return AssignedOrderMaterialFormData(
      id: null,
      assignedOrderId: assignedOrderId,

      material: null,
      location: null,
      stockMaterialFound: true,

      name: "",
      identifier: "",
      amount: "",
      typeAheadStock: "",
      typeAheadAll: "",
      quotationMaterials: null
    );
  }

  AssignedOrderMaterial toModel() {
    double amount = double.parse(this.amount!);
    return AssignedOrderMaterial(
        id: this.id,
        assignedOrderId: this.assignedOrderId,
        material: this.material,
        location: this.location,
        materialName: this.name,
        materialIdentifier: this.identifier,
        amount: amount
    );
  }

  bool isValid() {
    if (isEmpty("${this.material}") || isEmpty("${this.location}")) {
      return false;
    }

    return true;
  }
}
