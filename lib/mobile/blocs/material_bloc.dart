import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:logging/logging.dart';

import 'package:my24app/mobile/models/material/api.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/models/material/form_data.dart';
import 'package:my24app/mobile/models/material/models.dart';

final log = Logger('mobile.blocs.material_bloc');

enum AssignedOrderMaterialEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  DO_SEARCH,
  FETCH_DETAIL,
  NEW,
  NEW_EMPTY,
  DELETE,
  UPDATE,
  INSERT,
  UPDATE_FORM_DATA,
  materialCreated
}

class AssignedOrderMaterialEvent {
  final int? pk;
  final int? assignedOrderId;
  final dynamic status;
  final AssignedOrderMaterial? material;
  final AssignedOrderMaterialFormData? materialFormData;
  final int? page;
  final String? query;

  const AssignedOrderMaterialEvent({
    this.pk,
    this.assignedOrderId,
    this.status,
    this.material,
    this.materialFormData,
    this.page,
    this.query,
  });
}

class AssignedOrderMaterialBloc extends Bloc<AssignedOrderMaterialEvent, AssignedOrderMaterialState> {
  AssignedOrderMaterialApi api = AssignedOrderMaterialApi();

  AssignedOrderMaterialBloc() : super(MaterialInitialState()) {
    on<AssignedOrderMaterialEvent>((event, emit) async {
      if (event.status == AssignedOrderMaterialEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.FETCH_DETAIL) {
        await _handleFetchState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.NEW) {
        _handleNewFormDataState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.NEW_EMPTY) {
        _handleNewEmptyFormDataState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.materialCreated) {
        _handleMaterialCreatedState(event, emit);
      }

    },
    transformer: sequential());
  }

  void _handleMaterialCreatedState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialNewMaterialCreatedState(materialFormData: event.materialFormData));
  }

  void _handleUpdateFormDataState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialLoadedState(materialFormData: event.materialFormData));
  }

  void _handleDoSearchState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialSearchState());
  }

  void _handleNewFormDataState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialNewState(
        materialFormData: AssignedOrderMaterialFormData.createEmpty(event.assignedOrderId)
    ));
  }

  void _handleNewEmptyFormDataState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialNewState(
        materialFormData: AssignedOrderMaterialFormData.createEmpty(event.assignedOrderId)
    ));
  }

  void _handleDoAsyncState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialLoadingState());
  }

  Future<void> _handleFetchAllState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
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
      log.severe("fetch all: $e");
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterial material = await api.detail(event.pk!);
      emit(MaterialLoadedState(
          materialFormData: AssignedOrderMaterialFormData.createFromModel(material)
      ));
    } catch(e) {
      log.severe("fetch: $e");
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterial material = await api.insert(
          event.material!);
      emit(MaterialInsertedState(material: material));
    } catch(e) {
      log.severe("insert: $e");
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterial material = await api.update(event.pk!, event.material!);
      emit(MaterialUpdatedState(material: material));
    } catch(e) {
      log.severe("edit: $e");
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final bool result = await api.delete(event.pk!);
      emit(MaterialDeletedState(result: result));
    } catch(e) {
      log.severe("delete: $e");
      emit(MaterialErrorState(message: e.toString()));
    }
  }
}
