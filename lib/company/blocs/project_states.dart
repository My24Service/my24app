import 'package:equatable/equatable.dart';

import 'package:my24app/company/models/project/form_data.dart';
import 'package:my24app/company/models/project/models.dart';

abstract class ProjectState extends Equatable {}

class ProjectInitialState extends ProjectState {
  @override
  List<Object> get props => [];
}

class ProjectLoadingState extends ProjectState {
  @override
  List<Object> get props => [];
}

class ProjectSearchState extends ProjectState {
  @override
  List<Object> get props => [];
}

class ProjectErrorState extends ProjectState {
  final String message;

  ProjectErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class ProjectInsertedState extends ProjectState {
  final Project project;

  ProjectInsertedState({this.project});

  @override
  List<Object> get props => [project];
}


class ProjectUpdatedState extends ProjectState {
  final Project project;

  ProjectUpdatedState({this.project});

  @override
  List<Object> get props => [project];
}

class ProjectsLoadedState extends ProjectState {
  final Projects projects;
  final int page;
  final String query;

  ProjectsLoadedState({
    this.projects,
    this.page,
    this.query
  });

  @override
  List<Object> get props => [projects, page, query];
}

class ProjectLoadedState extends ProjectState {
  final ProjectFormData formData;

  ProjectLoadedState({this.formData});

  @override
  List<Object> get props => [formData];
}

class ProjectNewState extends ProjectState {
  final ProjectFormData formData;
  final bool fromEmpty;

  ProjectNewState({
    this.formData,
    this.fromEmpty
  });

  @override
  List<Object> get props => [formData, fromEmpty];
}

class ProjectDeletedState extends ProjectState {
  final bool result;

  ProjectDeletedState({this.result});

  @override
  List<Object> get props => [result];
}
