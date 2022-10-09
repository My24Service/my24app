import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/company/api/company_api.dart';
import 'package:my24app/company/blocs/project_states.dart';
import 'package:my24app/company/models/models.dart';

enum ProjectEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  INSERT,
  NEW,
  EDIT,
  DELETE,
}

class ProjectEvent {
  final ProjectEventStatus status;
  final int pk;
  final Project project;

  const ProjectEvent({
    this.status,
    this.pk,
    this.project,
  });
}

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  CompanyApi localCompanyApi = companyApi;

  ProjectBloc() : super(ProjectInitialState()) {
    on<ProjectEvent>((event, emit) async {
      if (event.status == ProjectEventStatus.NEW) {
        _handleNewState(event, emit);
      }
      if (event.status == ProjectEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == ProjectEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == ProjectEventStatus.FETCH_DETAIL) {
        await _handleFetchDetailState(event, emit);
      }
      else if (event.status == ProjectEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == ProjectEventStatus.EDIT) {
        await _handleEditState(event, emit);
      }
      else if (event.status == ProjectEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleNewState(ProjectEvent event, Emitter<ProjectState> emit) {
    emit(ProjectNewState());
  }

  void _handleDoAsyncState(ProjectEvent event, Emitter<ProjectState> emit) {
    emit(ProjectLoadingState());
  }

  Future<void> _handleFetchAllState(ProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      final ProjectsPaginated result = await localCompanyApi.fetchProjects();
      emit(ProjectsLoadedState(result: result));
    } catch (e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailState(ProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      final Project project = await localCompanyApi.fetchProjectDetail(event.pk);
      emit(ProjectLoadedState(project: project));
    } catch(e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(ProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      final Project project = await localCompanyApi.insertProject(event.project);
      emit(ProjectInsertedState(project: project));
    } catch(e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(ProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      final bool result = await localCompanyApi.editProject(event.pk, event.project);
      emit(ProjectEditedState(result: result));
    } catch(e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(ProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      final bool result = await localCompanyApi.deleteProject(event.pk);
      emit(ProjectDeletedState(result: result));
    } catch (e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }
}
