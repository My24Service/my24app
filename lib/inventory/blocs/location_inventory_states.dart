import 'package:equatable/equatable.dart';

import '../models/location/form_data.dart';

abstract class LocationInventoryState extends Equatable {}

class LocationInventoryInitialState extends LocationInventoryState {
  @override
  List<Object> get props => [];
}

class LocationInventoryLoadingState extends LocationInventoryState {
  @override
  List<Object> get props => [];
}

class LocationInventoryErrorState extends LocationInventoryState {
  final String? message;

  LocationInventoryErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class LocationInventoryNewState extends LocationInventoryState {
  final LocationsDataFormData? formData;

  LocationInventoryNewState({this.formData});

  @override
  List<Object?> get props => [formData];
}

class LocationInventoryLoadedState extends LocationInventoryState {
  final LocationsDataFormData? formData;

  LocationInventoryLoadedState({this.formData});

  @override
  List<Object?> get props => [formData];
}
