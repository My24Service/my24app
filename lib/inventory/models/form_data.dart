import 'package:my24app/core/models/base_models.dart';
import 'models.dart';

class LocationsDataFormData extends BaseFormData<LocationsData>  {
  StockLocations locations;
  List<LocationMaterialInventory> locationProducts;
  String location;
  int locationId;

  LocationsDataFormData({
    this.locations,
    this.locationProducts,
    this.location,
    this.locationId,
  });

  factory LocationsDataFormData.createFromModel(LocationsData data) {
    // we're not using this
    return LocationsDataFormData();
  }

  factory LocationsDataFormData.createEmpty() {
    return LocationsDataFormData(
    );
  }

  LocationsData toModel() {
    // we're not using this
    return LocationsData();
  }

  bool isValid() {
    return true;
  }
}
