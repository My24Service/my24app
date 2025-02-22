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

class MaterialSearchState extends AssignedOrderMaterialState {
  @override
  List<Object> get props => [];
}

class MaterialErrorState extends AssignedOrderMaterialState {
  final String? message;

  MaterialErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class MaterialInsertedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterial? material;

  MaterialInsertedState({this.material});

  @override
  List<Object?> get props => [material];
}

class MaterialsInsertedState extends AssignedOrderMaterialState {
  final List<AssignedOrderMaterial>? materials;

  MaterialsInsertedState({this.materials});

  @override
  List<Object?> get props => [materials];
}


class MaterialUpdatedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterial? material;

  MaterialUpdatedState({this.material});

  @override
  List<Object?> get props => [material];
}

class MaterialsLoadedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterials? materials;
  final int? page;
  final String? query;

  MaterialsLoadedState({
    this.materials,
    this.page,
    this.query
  });

  @override
  List<Object?> get props => [materials, page, query];
}

class MaterialLoadedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterialFormData? materialFormData;

  MaterialLoadedState({this.materialFormData});

  @override
  List<Object?> get props => [materialFormData];
}

class MaterialNewMaterialCreatedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterialFormData? materialFormData;

  MaterialNewMaterialCreatedState({this.materialFormData});

  @override
  List<Object?> get props => [materialFormData];
}

class MaterialNewState extends AssignedOrderMaterialState {
  final AssignedOrderMaterialFormData? materialFormData;
  final bool? fromEmpty;

  MaterialNewState({
    this.materialFormData,
    this.fromEmpty,
  });

  @override
  List<Object?> get props => [materialFormData, fromEmpty];
}

class MaterialDeletedState extends AssignedOrderMaterialState {
  final bool? result;

  MaterialDeletedState({this.result});

  @override
  List<Object?> get props => [result];
}
