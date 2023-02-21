import 'package:equatable/equatable.dart';

import 'package:my24app/mobile/models/material/form_data.dart';
import 'package:my24app/mobile/models/material/models.dart';

abstract class AssignedOrderMaterialState extends Equatable {}

class MaterialInitialState extends AssignedOrderMaterialState {
  @override
  List<Object> get props => [];
}

class MaterialLoadingState extends AssignedOrderMaterialState {
  @override
  List<Object> get props => [];
}

class MaterialErrorState extends AssignedOrderMaterialState {
  final String message;

  MaterialErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class MaterialInsertedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterial material;

  MaterialInsertedState({this.material});

  @override
  List<Object> get props => [material];
}


class MaterialUpdatedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterial material;

  MaterialUpdatedState({this.material});

  @override
  List<Object> get props => [material];
}

class MaterialsLoadedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterials materials;

  MaterialsLoadedState({this.materials});

  @override
  List<Object> get props => [materials];
}

class MaterialLoadedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterialFormData materialFormData;

  MaterialLoadedState({this.materialFormData});

  @override
  List<Object> get props => [materialFormData];
}

class MaterialNewState extends AssignedOrderMaterialState {
  final AssignedOrderMaterialFormData materialFormData;

  MaterialNewState({this.materialFormData});

  @override
  List<Object> get props => [materialFormData];
}

class MaterialDeletedState extends AssignedOrderMaterialState {
  final bool result;

  MaterialDeletedState({this.result});

  @override
  List<Object> get props => [result];
}
