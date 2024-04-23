import 'package:equatable/equatable.dart';

import 'package:my24app/inventory/models/supplier/form_data.dart';
import 'package:my24app/inventory/models/supplier/models.dart';

import '../models/material/form_data.dart';

abstract class SupplierState extends Equatable {}

class SupplierInitialState extends SupplierState {
  @override
  List<Object> get props => [];
}

class SupplierLoadingState extends SupplierState {
  @override
  List<Object> get props => [];
}

class SupplierCancelCreateState extends SupplierState {
  @override
  List<Object> get props => [];
}

class SupplierSearchState extends SupplierState {
  @override
  List<Object> get props => [];
}

class SupplierErrorState extends SupplierState {
  final String? message;

  SupplierErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class SupplierInsertedState extends SupplierState {
  final Supplier? supplier;
  final MaterialFormData? materialFormData;

  SupplierInsertedState({
    this.supplier,
    this.materialFormData
  });

  @override
  List<Object?> get props => [supplier, materialFormData];
}


class SupplierUpdatedState extends SupplierState {
  final Supplier? supplier;

  SupplierUpdatedState({this.supplier});

  @override
  List<Object?> get props => [supplier];
}

class SuppliersLoadedState extends SupplierState {
  final Suppliers? suppliers;
  final int? page;
  final String? query;

  SuppliersLoadedState({
    this.suppliers,
    this.page,
    this.query
  });

  @override
  List<Object?> get props => [suppliers, page, query];
}

class SupplierLoadedState extends SupplierState {
  final SupplierFormData? supplierFormData;

  SupplierLoadedState({this.supplierFormData});

  @override
  List<Object?> get props => [supplierFormData];
}

class SupplierNewState extends SupplierState {
  final SupplierFormData? supplierFormData;
  final bool? fromEmpty;

  SupplierNewState({
    this.supplierFormData,
    this.fromEmpty
  });

  @override
  List<Object?> get props => [supplierFormData, fromEmpty];
}

class SupplierDeletedState extends SupplierState {
  final bool? result;

  SupplierDeletedState({this.result});

  @override
  List<Object?> get props => [result];
}
