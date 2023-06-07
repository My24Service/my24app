import 'package:equatable/equatable.dart';

import '../../models.dart';

abstract class PreferencesState extends Equatable {}

class PreferencesInitialState extends PreferencesState {
  @override
  List<Object> get props => [];
}

class PreferencesReadState extends PreferencesState {
  final String? value;

  PreferencesReadState({this.value});

  @override
  List<Object?> get props => [value];
}

class PreferencesLoadedState extends PreferencesState {
  final PreferencesFormData? formData;

  PreferencesLoadedState({this.formData});

  @override
  List<Object?> get props => [formData];
}

class PreferencesLoadingState extends PreferencesState {
  @override
  List<Object> get props => [];
}

class PreferencesErrorState extends PreferencesState {
  final String? message;

  PreferencesErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class PreferencesUpdatedState extends PreferencesState {
  final String? preferedLanguageCode;

  PreferencesUpdatedState({this.preferedLanguageCode});

  @override
  List<Object?> get props => [preferedLanguageCode];
}
