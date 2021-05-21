import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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
  MaterialBloc(AssignedOrderMaterialState initialState) : super(initialState);

  @override
  Stream<AssignedOrderMaterialState> mapEventToState(event) async* {
    if (event.status == MaterialEventStatus.DO_ASYNC) {
      yield MaterialLoadingState();
    }
    if (event.status == MaterialEventStatus.FETCH_ALL) {
      try {
        final AssignedOrderMaterials materials = await localMobileApi.fetchAssignedOrderMaterials(event.value);
        yield MaterialsLoadedState(materials: materials);
      } catch(e) {
        yield MaterialErrorState(message: e.toString());
      }
    }

    if (event.status == MaterialEventStatus.INSERTED) {
      yield MaterialInsertedState();
    }

    if (event.status == MaterialEventStatus.UPDATED) {
      yield MaterialUpdatedState();
    }

    if (event.status == MaterialEventStatus.DELETE) {
      try {
        final bool result = await localMobileApi.deleteAssignedOrderMaterial(event.value);
        yield MaterialDeletedState(result: result);
      } catch(e) {
        yield MaterialErrorState(message: e.toString());
      }
    }
  }
}
