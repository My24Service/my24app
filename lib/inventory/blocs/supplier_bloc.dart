import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:logging/logging.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/utils.dart';

import 'package:my24app/inventory/models/supplier/api.dart';
import 'package:my24app/inventory/blocs/supplier_states.dart';
import 'package:my24app/inventory/models/supplier/form_data.dart';
import 'package:my24app/inventory/models/supplier/models.dart';

import '../models/material/form_data.dart';

final log = Logger('inventory.blocs.supplier_bloc');

enum SupplierEventStatus {
  doAsync,
  newModel,
  newEmpty,
  delete,
  update,
  insert,
  updateFormData,
  cancelCreate,
  getAddressFromLocation
}

class SupplierEvent {
  final int? pk;
  final dynamic status;
  final Supplier? supplier;
  final SupplierFormData? supplierFormData;
  final MaterialFormData? materialFormData;
  final int? page;
  final String? query;

  const SupplierEvent({
    this.pk,
    this.status,
    this.supplier,
    this.supplierFormData,
    this.materialFormData,
    this.page,
    this.query,
  });
}

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  SupplierApi api = SupplierApi();
  CoreUtils coreUtils = CoreUtils();

  SupplierBloc() : super(SupplierInitialState()) {
    on<SupplierEvent>((event, emit) async {
      if (event.status == SupplierEventStatus.doAsync) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == SupplierEventStatus.insert) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == SupplierEventStatus.update) {
        await _handleEditState(event, emit);
      }
      else if (event.status == SupplierEventStatus.delete) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == SupplierEventStatus.updateFormData) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == SupplierEventStatus.newModel) {
        _handleNewFormDataState(event, emit);
      }
      else if (event.status == SupplierEventStatus.newEmpty) {
        _handleNewEmptyFormDataState(event, emit);
      }
      else if (event.status == SupplierEventStatus.cancelCreate) {
        _handleCancelCreateState(event, emit);
      }
      else if (event.status == SupplierEventStatus.getAddressFromLocation) {
        await _handleGetAddressFromLocationState(event, emit);
      }

    },
    transformer: sequential());
  }

  void _handleUpdateFormDataState(SupplierEvent event, Emitter<SupplierState> emit) {
    emit(SupplierLoadedState(supplierFormData: event.supplierFormData));
  }

  void _handleCancelCreateState(SupplierEvent event, Emitter<SupplierState> emit) {
    emit(SupplierCancelCreateState());
  }

  void _handleNewFormDataState(SupplierEvent event, Emitter<SupplierState> emit) {
    emit(SupplierNewState(
        supplierFormData: SupplierFormData.createEmpty()
    ));
  }

  void _handleNewEmptyFormDataState(SupplierEvent event, Emitter<SupplierState> emit) {
    emit(SupplierNewState(
        supplierFormData: SupplierFormData.createEmpty()
    ));
  }

  void _handleDoAsyncState(SupplierEvent event, Emitter<SupplierState> emit) {
    emit(SupplierLoadingState());
  }

  Future<void> _handleInsertState(SupplierEvent event, Emitter<SupplierState> emit) async {
    try {
      final Supplier supplier = await api.insert(event.supplier!);
      emit(SupplierInsertedState(supplier: supplier, materialFormData: event.materialFormData!));
    } catch(e) {
      log.severe("insert: $e");
      emit(SupplierErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(SupplierEvent event, Emitter<SupplierState> emit) async {
    try {
      final Supplier supplier = await api.update(event.pk!, event.supplier!);
      emit(SupplierUpdatedState(supplier: supplier));
    } catch(e) {
      log.severe("edit: $e");
      emit(SupplierErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(SupplierEvent event, Emitter<SupplierState> emit) async {
    try {
      final bool result = await api.delete(event.pk!);
      emit(SupplierDeletedState(result: result));
    } catch(e) {
      log.severe("delete: $e");
      emit(SupplierErrorState(message: e.toString()));
    }
  }

  Future<void> _handleGetAddressFromLocationState(SupplierEvent event, Emitter<SupplierState> emit) async {
    try {
      final SimpleAddress? address = await coreUtils.positionToAddress();
      if (address != null) {
        event.supplierFormData!.address = address.street;
        event.supplierFormData!.postal = address.postal;
        event.supplierFormData!.city = address.city;
        event.supplierFormData!.country_code = address.countryCode;
      }

      emit(SupplierAddressReceivedState(
          supplierFormData: event.supplierFormData));
    } catch(e) {
      log.severe("address from location: $e");
      emit(SupplierErrorState(message: e.toString()));
    }
  }
}
