import 'package:equatable/equatable.dart';

import 'package:my24app/company/models/models.dart';

abstract class ProjectState extends Equatable {}

class ProjectInitialState extends ProjectState {
  @override
  List<Object> get props => [];
}

class ProjectNewState extends ProjectState {
  @override
  List<Object> get props => [];
}

class ProjectLoadingState extends ProjectState {
  @override
  List<Object> get props => [];
}

class ProjectErrorState extends ProjectState {
  final String message;

  ProjectErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class ProjectsLoadedState extends ProjectState {
  final ProjectsPaginated result;

  ProjectsLoadedState({this.result});

  @override
  List<Object> get props => [result];
}

class ProjectInsertedState extends ProjectState {
  final Project project;

  ProjectInsertedState({this.project});

  @override
  List<Object> get props => [project];
}

class ProjectEditedState extends ProjectState {
  final bool result;

  ProjectEditedState({this.result});

  @override
  List<Object> get props => [result];
}

class ProjectDeletedState extends ProjectState {
  final bool result;

  ProjectDeletedState({this.result});

  @override
  List<Object> get props => [result];
}

class ProjectLoadedState extends ProjectState {
  final Project project;

  ProjectLoadedState({this.project});

  @override
  List<Object> get props => [project];
}
