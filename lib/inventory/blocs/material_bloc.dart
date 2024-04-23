import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:logging/logging.dart';

import 'package:my24app/inventory/models/material/api.dart';
import 'package:my24app/inventory/blocs/material_states.dart';
import 'package:my24app/inventory/models/material/form_data.dart';
import 'package:my24app/inventory/models/material/models.dart';

final log = Logger('inventory.blocs.material_bloc');

enum MaterialEventStatus {
  doAsync,
  newModel,
  newEmpty,
  delete,
  update,
  insert,
  updateFormData,
  cancelCreate,
  supplierCreated
}

class MaterialEvent {
  final int? pk;
  final dynamic status;
  final MaterialModel? material;
  final MaterialFormData? materialFormData;
  final int? page;
  final String? query;

  const MaterialEvent({
    this.pk,
    this.status,
    this.material,
    this.materialFormData,
    this.page,
    this.query,
  });
}

class MaterialBloc extends Bloc<MaterialEvent, MyMaterialState> {
  MaterialApi api = MaterialApi();

  MaterialBloc() : super(MaterialInitialState()) {
    on<MaterialEvent>((event, emit) async {
      if (event.status == MaterialEventStatus.doAsync) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == MaterialEventStatus.insert) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == MaterialEventStatus.update) {
        await _handleEditState(event, emit);
      }
      else if (event.status == MaterialEventStatus.delete) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == MaterialEventStatus.updateFormData) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == MaterialEventStatus.newModel) {
        _handleNewFormDataState(event, emit);
      }
      else if (event.status == MaterialEventStatus.newEmpty) {
        _handleNewEmptyFormDataState(event, emit);
      }
      else if (event.status == MaterialEventStatus.cancelCreate) {
        _handleCancelCreateState(event, emit);
      }
      else if (event.status == MaterialEventStatus.supplierCreated) {
        _handleSupplierCreatedState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleSupplierCreatedState(MaterialEvent event, Emitter<MyMaterialState> emit) {
    emit(MaterialSupplierCreatedState(materialFormData: event.materialFormData));
  }

  void _handleUpdateFormDataState(MaterialEvent event, Emitter<MyMaterialState> emit) {
    emit(MaterialLoadedState(materialFormData: event.materialFormData));
  }

  void _handleCancelCreateState(MaterialEvent event, Emitter<MyMaterialState> emit) {
    emit(MaterialCancelCreateState());
  }

  void _handleNewFormDataState(MaterialEvent event, Emitter<MyMaterialState> emit) {
    emit(MaterialNewState(
        materialFormData: MaterialFormData.createEmpty()
    ));
  }

  void _handleNewEmptyFormDataState(MaterialEvent event, Emitter<MyMaterialState> emit) {
    emit(MaterialNewState(
        materialFormData: MaterialFormData.createEmpty()
    ));
  }

  void _handleDoAsyncState(MaterialEvent event, Emitter<MyMaterialState> emit) {
    emit(MaterialLoadingState());
  }

  Future<void> _handleInsertState(MaterialEvent event, Emitter<MyMaterialState> emit) async {
    try {
      final MaterialModel material = await api.insert(event.material!);
      emit(MaterialInsertedState(material: material));
    } catch(e) {
      log.severe(e);
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(MaterialEvent event, Emitter<MyMaterialState> emit) async {
    try {
      final MaterialModel material = await api.update(event.pk!, event.material!);
      emit(MaterialUpdatedState(material: material));
    } catch(e) {
      log.severe(e);
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(MaterialEvent event, Emitter<MyMaterialState> emit) async {
    try {
      final bool result = await api.delete(event.pk!);
      emit(MaterialDeletedState(result: result));
    } catch(e) {
      log.severe(e);
      emit(MaterialErrorState(message: e.toString()));
    }
  }
}
