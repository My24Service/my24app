import 'package:equatable/equatable.dart';
import 'package:my24app/mobile/models/models.dart';

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

class MaterialsLoadedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterials materials;

  MaterialsLoadedState({this.materials});

  @override
  List<Object> get props => [materials];
}

class MaterialLoadedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterial material;

  MaterialLoadedState({this.material});

  @override
  List<Object> get props => [material];
}

class MaterialDeletedState extends AssignedOrderMaterialState {
  final bool result;

  MaterialDeletedState({this.result});

  @override
  List<Object> get props => [result];
}

class MaterialInsertedState extends AssignedOrderMaterialState {
  final AssignedOrderMaterial material;

  MaterialInsertedState({this.material});

  @override
  List<Object> get props => [material];
}
