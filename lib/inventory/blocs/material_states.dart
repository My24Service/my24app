import 'package:equatable/equatable.dart';

import 'package:my24app/inventory/models/material/form_data.dart';
import 'package:my24app/inventory/models/material/models.dart';

abstract class MyMaterialState extends Equatable {}

class MaterialInitialState extends MyMaterialState {
  @override
  List<Object> get props => [];
}

class MaterialLoadingState extends MyMaterialState {
  @override
  List<Object> get props => [];
}

class MaterialCancelCreateState extends MyMaterialState {
  @override
  List<Object> get props => [];
}

class MaterialSupplierCreatedState extends MyMaterialState {
  final MaterialFormData? materialFormData;

  MaterialSupplierCreatedState({this.materialFormData});

  @override
  List<Object?> get props => [materialFormData];
}

class MaterialSearchState extends MyMaterialState {
  @override
  List<Object> get props => [];
}

class MaterialErrorState extends MyMaterialState {
  final String? message;

  MaterialErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class MaterialInsertedState extends MyMaterialState {
  final MaterialModel? material;

  MaterialInsertedState({this.material});

  @override
  List<Object?> get props => [material];
}


class MaterialUpdatedState extends MyMaterialState {
  final MaterialModel? material;

  MaterialUpdatedState({this.material});

  @override
  List<Object?> get props => [material];
}

class MaterialsLoadedState extends MyMaterialState {
  final Materials? materials;
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

class MaterialLoadedState extends MyMaterialState {
  final MaterialFormData? materialFormData;

  MaterialLoadedState({this.materialFormData});

  @override
  List<Object?> get props => [materialFormData];
}

class MaterialNewState extends MyMaterialState {
  final MaterialFormData? materialFormData;
  final bool? fromEmpty;

  MaterialNewState({
    this.materialFormData,
    this.fromEmpty
  });

  @override
  List<Object?> get props => [materialFormData, fromEmpty];
}

class MaterialDeletedState extends MyMaterialState {
  final bool? result;

  MaterialDeletedState({this.result});

  @override
  List<Object?> get props => [result];
}
