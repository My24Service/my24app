import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final String preferedLanguageCode;

  Preferences(
    this.preferedLanguageCode
  );
}

enum EventStatus { READ, WRITE }

class PreferencesEvent {
  final String value;
  final EventStatus status;

  const PreferencesEvent({this.value, this.status});
}

abstract class PreferencesState extends Equatable {}

class PreferencesInitialState extends PreferencesState {
  @override
  List<Object> get props => [];
}
class PreferencesReadState extends PreferencesState {
  final String value;

  PreferencesReadState({this.value});

  @override
  List<Object> get props => [value];
}

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  SharedPreferences _sPrefs;

  PreferencesBloc() : super(PreferencesInitialState()) {
    on<PreferencesEvent>((event, emit) async {
      if (event.status == EventStatus.READ) {
        await _handleReadState(event, emit);
      }
    },
    transformer: sequential());
  }

  Future<void> _handleReadState(PreferencesEvent event, Emitter<PreferencesState> emit) async {
    final preferenceValue = await _getPreference(event.value);
    emit(PreferencesReadState(value: preferenceValue));
  }

  Future<String> _getPreference(String key) async {
    if (_sPrefs == null) {
      _sPrefs = await SharedPreferences.getInstance();
    }

    return _sPrefs.getString(key);
  }

  void dispose() {}
}
