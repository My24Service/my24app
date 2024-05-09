import 'package:my24_flutter_core/models/base_models.dart';
import 'models.dart';

class SupplierFormData extends BaseFormData<Supplier>  {
  int? id;
  String? name;
  String? address;
  String? postal;
  String? country_code;
  String? city;

  dynamic getProp(String key) => <String, dynamic>{
    'name': name,
    'address': address,
    'postal': postal,
    'country_code': country_code,
    'city': city,
  }[key];

  dynamic setProp(String key, String value) {
    switch (key) {
      case 'name': {
        this.name = value;
      }
      break;

      case 'address': {
        this.address = value;
      }
      break;

      case 'postal': {
        this.postal = value;
      }
      break;

      case 'country_code': {
        this.country_code = value;
      }
      break;

      case 'city': {
        this.city = value;
      }
      break;

      default:
        {
          throw Exception("unknown field: $key");
        }
    }
  }

  SupplierFormData({
    this.id,
    this.name,
    this.address,
    this.postal,
    this.country_code,
    this.city,
  });

  factory SupplierFormData.createFromModel(Supplier supplier) {
    return SupplierFormData(
      id: supplier.id,
      name: checkNull(supplier.name),
      address: checkNull(supplier.address),
      postal: checkNull(supplier.postal),
      country_code: checkNull(supplier.country_code),
      city: checkNull(supplier.city),
    );
  }

  factory SupplierFormData.createEmpty() {
    return SupplierFormData(
      id: null,
      name: "",
      address: "",
      postal: "",
      country_code: "NL",
      city: "",
    );
  }

  Supplier toModel() {
    return Supplier(
      id: this.id,
      name: this.name,
      address: this.address,
      postal: this.postal,
      country_code: this.country_code,
      city: this.city,
    );
  }

  bool isValid() {
    if (isEmpty(this.name) || isEmpty(this.address) || isEmpty(this.postal) || isEmpty(this.city)) {
      return false;
    }

    return true;
  }
}
