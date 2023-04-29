import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/company/blocs/project_states.dart';
import 'package:my24app/company/models/project/models.dart';
import 'package:my24app/company/models/project/api.dart';

import '../models/project/form_data.dart';

enum ProjectEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  FETCH_DETAIL,
  DO_SEARCH,
  NEW,
  NEW_EMPTY,
  DELETE,
  UPDATE,
  INSERT,
  UPDATE_FORM_DATA
}

class ProjectEvent {
  final ProjectEventStatus status;
  final int pk;
  final Project project;
  final ProjectFormData formData;
  final int page;
  final String query;

  const ProjectEvent({
    this.status,
    this.pk,
    this.project,
    this.formData,
    this.query,
    this.page
  });
}

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectApi api = ProjectApi();

  ProjectBloc() : super(ProjectInitialState()) {
    on<ProjectEvent>((event, emit) async {
      if (event.status == ProjectEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == ProjectEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == ProjectEventStatus.FETCH_DETAIL) {
        await _handleFetchState(event, emit);
      }
      else if (event.status == ProjectEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == ProjectEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == ProjectEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == ProjectEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == ProjectEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == ProjectEventStatus.NEW) {
        _handleNewFormDataState(event, emit);
      }
      else if (event.status == ProjectEventStatus.NEW_EMPTY) {
        _handleNewEmptyFormDataState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleUpdateFormDataState(ProjectEvent event, Emitter<ProjectState> emit) {
    emit(ProjectLoadedState(formData: event.formData));
  }

  void _handleDoSearchState(ProjectEvent event, Emitter<ProjectState> emit) {
    emit(ProjectSearchState());
  }

  void _handleNewFormDataState(ProjectEvent event, Emitter<ProjectState> emit) {
    emit(ProjectNewState(
        formData: ProjectFormData.createEmpty()
    ));
  }

  void _handleNewEmptyFormDataState(ProjectEvent event, Emitter<ProjectState> emit) {
    emit(ProjectNewState(
        formData: ProjectFormData.createEmpty()
    ));
  }

  void _handleDoAsyncState(ProjectEvent event, Emitter<ProjectState> emit) {
    emit(ProjectLoadingState());
  }

  Future<void> _handleFetchAllState(ProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      final Projects projects = await api.list(
          filters: {
            'query': event.query,
            'page': event.page
          });
      emit(ProjectsLoadedState(projects: projects));
    } catch(e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(ProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      final Project project = await api.detail(event.pk);
      emit(ProjectLoadedState(
          formData: ProjectFormData.createFromModel(project)
      ));
    } catch(e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(ProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      final Project project = await api.insert(event.project);
      emit(ProjectInsertedState(project: project));
    } catch(e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(ProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      final Project project = await api.update(event.pk, event.project);
      emit(ProjectUpdatedState(project: project));
    } catch(e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(ProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      final bool result = await api.delete(event.pk);
      emit(ProjectDeletedState(result: result));
    } catch(e) {
      emit(ProjectErrorState(message: e.toString()));
    }
  }
}
