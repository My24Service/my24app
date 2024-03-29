import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models.dart';
import 'states.dart';

enum PreferencesEventStatus {
  DO_ASYNC,
  UPDATE_FORM_DATA,
  FETCH,
  UPDATE
}

class PreferencesEvent {
  final PreferencesFormData? formData;
  final PreferencesEventStatus? status;

  const PreferencesEvent({
    this.formData,
    this.status
  });
}

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  PreferencesBloc() : super(PreferencesInitialState()) {
    on<PreferencesEvent>((event, emit) async {
      if (event.status == PreferencesEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == PreferencesEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == PreferencesEventStatus.FETCH) {
        await _handleFetch(event, emit);
      }
      else if (event.status == PreferencesEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
    },
        transformer: sequential());
  }

  void _handleUpdateFormDataState(PreferencesEvent event, Emitter<PreferencesState> emit) {
    emit(PreferencesLoadedState(formData: event.formData));
  }

  void _handleDoAsyncState(PreferencesEvent event, Emitter<PreferencesState> emit) {
    emit(PreferencesLoadingState());
  }

  Future<void> _handleFetch(PreferencesEvent event, Emitter<PreferencesState> emit) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? preferredMemberCompanyCode = prefs.getString('companycode');
      int? preferredMemberPk = prefs.getInt('member_pk');

      // override if set
      if (prefs.containsKey('preferred_companycode')) {
        preferredMemberCompanyCode = prefs.getString('preferred_companycode');
      }

      if (prefs.containsKey('preferred_member_pk')) {
        preferredMemberPk = prefs.getInt('preferred_member_pk');
      }

      bool? skipMemberList = false;
      if (prefs.containsKey('skip_member_list')) {
        skipMemberList = prefs.getBool('skip_member_list');
      }

      PreferencesFormData formData = PreferencesFormData(
          preferredMemberCompanyCode: preferredMemberCompanyCode,
          preferredMemberPk: preferredMemberPk,
          preferredLanguageCode: prefs.getString('preferred_language_code'),
          skipMemberList: skipMemberList
      );

      emit(PreferencesLoadedState(formData: formData));
    } catch(e) {
      emit(PreferencesErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(PreferencesEvent event, Emitter<PreferencesState> emit) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('skip_member_list', event.formData!.skipMemberList!);

      if (event.formData!.skipMemberList!) {
        prefs.setInt('preferred_member_pk', event.formData!.preferredMemberPk!);
        prefs.setString('preferred_companycode', event.formData!.preferredMemberCompanyCode!);
      } else {
        prefs.remove('preferred_member_pk');
        prefs.remove('preferred_companycode');
      }

      prefs.setString('preferred_language_code', event.formData!.preferredLanguageCode!);

      // pass language for setting it in the context
      emit(PreferencesUpdatedState(
          preferredLanguageCode: event.formData!.preferredLanguageCode
      ));
    } catch(e) {
      emit(PreferencesErrorState(message: e.toString()));
    }
  }

  void dispose() {}
}
