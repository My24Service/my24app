import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/mobile/models/material/api.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/models/material/form_data.dart';
import 'package:my24app/mobile/models/material/models.dart';

enum MaterialEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  DO_SEARCH,
  FETCH_DETAIL,
  NEW,
  NEW_EMPTY,
  DELETE,
  UPDATE,
  INSERT,
  UPDATE_FORM_DATA
}

class MaterialEvent {
  final int? pk;
  final int? assignedOrderId;
  final dynamic status;
  final AssignedOrderMaterial? material;
  final AssignedOrderMaterialFormData? materialFormData;
  final int? page;
  final String? query;

  const MaterialEvent({
    this.pk,
    this.assignedOrderId,
    this.status,
    this.material,
    this.materialFormData,
    this.page,
    this.query,
  });
}

class MaterialBloc extends Bloc<MaterialEvent, AssignedOrderMaterialState> {
  MaterialApi api = MaterialApi();

  MaterialBloc() : super(MaterialInitialState()) {
    on<MaterialEvent>((event, emit) async {
      if (event.status == MaterialEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == MaterialEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == MaterialEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == MaterialEventStatus.FETCH_DETAIL) {
        await _handleFetchState(event, emit);
      }
      else if (event.status == MaterialEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == MaterialEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == MaterialEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == MaterialEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == MaterialEventStatus.NEW) {
        _handleNewFormDataState(event, emit);
      }
      else if (event.status == MaterialEventStatus.NEW_EMPTY) {
        _handleNewEmptyFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleUpdateFormDataState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialLoadedState(materialFormData: event.materialFormData));
  }

  void _handleDoSearchState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialSearchState());
  }

  void _handleNewFormDataState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialNewState(
        materialFormData: AssignedOrderMaterialFormData.createEmpty(event.assignedOrderId)
    ));
  }

  void _handleNewEmptyFormDataState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialNewState(
        materialFormData: AssignedOrderMaterialFormData.createEmpty(event.assignedOrderId)
    ));
  }

  void _handleDoAsyncState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialLoadingState());
  }

  Future<void> _handleFetchAllState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterials materials = await api.list(
          filters: {
            "assigned_order": event.assignedOrderId,
            'q': event.query,
            'page': event.page
          });
      emit(MaterialsLoadedState(
          materials: materials,
          query: event.query,
          page: event.page
      ));
    } catch(e) {
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterial material = await api.detail(event.pk!);
      emit(MaterialLoadedState(
          materialFormData: AssignedOrderMaterialFormData.createFromModel(material)
      ));
    } catch(e) {
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterial material = await api.insert(
          event.material!);
      emit(MaterialInsertedState(material: material));
    } catch(e) {
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterial material = await api.update(event.pk!, event.material!);
      emit(MaterialUpdatedState(material: material));
    } catch(e) {
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final bool result = await api.delete(event.pk!);
      emit(MaterialDeletedState(result: result));
    } catch(e) {
      print(e);
      emit(MaterialErrorState(message: e.toString()));
    }
  }
}
