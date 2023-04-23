import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../models/api.dart';
import '../models/form_data.dart';
import '../models/models.dart';
import 'location_inventory_states.dart';

enum LocationInventoryEventStatus {
  UPDATE_FORM_DATA,
  NEW,
  DO_ASYNC
}

class LocationInventoryEvent {
  final LocationsDataFormData formData;
  final LocationInventoryEventStatus status;

  const LocationInventoryEvent({
    this.formData,
    this.status
  });
}

class LocationInventoryBloc extends Bloc<LocationInventoryEvent, LocationInventoryState> {
  final api = InventoryApi();

  LocationInventoryBloc() : super(LocationInventoryInitialState()) {
    on<LocationInventoryEvent>((event, emit) async {
      if (event.status == LocationInventoryEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == LocationInventoryEventStatus.NEW) {
        _handleNewFormDataState(event, emit);
      }
      else if (event.status == LocationInventoryEventStatus.UPDATE_FORM_DATA) {
        await _handleUpdateFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  Future<void> _handleUpdateFormDataState(LocationInventoryEvent event, Emitter<LocationInventoryState> emit) async {
    try {
      List<LocationMaterialInventory> locationProducts = await api
          .searchLocationProducts(
          event.formData.locationId, ''
      );
      event.formData.locationProducts = locationProducts;

      emit(LocationInventoryLoadedState(formData: event.formData));
    } catch (e) {
      emit(LocationInventoryErrorState(message: e.toString()));
    }
  }

  void _handleNewFormDataState(LocationInventoryEvent event, Emitter<LocationInventoryState> emit) {
    emit(LocationInventoryNewState(
        formData: LocationsDataFormData.createEmpty()
    ));
  }

  void _handleDoAsyncState(LocationInventoryEvent event, Emitter<LocationInventoryState> emit) {
    emit(LocationInventoryLoadingState());
  }
}
