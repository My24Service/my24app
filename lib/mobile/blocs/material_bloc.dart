import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/mobile/api/mobile_api.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/models/models.dart';

enum MaterialEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  INSERTED,
  UPDATED,
  DELETE
}

class MaterialEvent {
  final dynamic status;
  final AssignedOrderMaterial material;
  final dynamic value;

  const MaterialEvent({this.status, this.material, this.value});
}

class MaterialBloc extends Bloc<MaterialEvent, AssignedOrderMaterialState> {
  MobileApi localMobileApi = mobileApi;

  MaterialBloc() : super(MaterialInitialState()) {
    on<MaterialEvent>((event, emit) async {
      if (event.status == MaterialEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      if (event.status == MaterialEventStatus.INSERTED) {
        _handleInsertedState(event, emit);
      }
      else if (event.status == MaterialEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == MaterialEventStatus.UPDATED) {
        _handleUpdatedState(event, emit);
      }
      else if (event.status == MaterialEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialLoadingState());
  }

  void _handleInsertedState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    // this is done via a direct API call
    emit(MaterialInsertedState());
  }

  Future<void> _handleFetchAllState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterials materials = await localMobileApi.fetchAssignedOrderMaterials(event.value);
      emit(MaterialsLoadedState(materials: materials));
    } catch(e) {
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  void _handleUpdatedState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    // this is done via a direct API call
    emit(MaterialUpdatedState());
  }

  Future<void> _handleDeleteState(MaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final bool result = await localMobileApi.deleteAssignedOrderMaterial(event.value);
      emit(MaterialDeletedState(result: result));
    } catch(e) {
      emit(MaterialErrorState(message: e.toString()));
    }
  }
}
