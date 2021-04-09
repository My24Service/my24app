import 'package:equatable/equatable.dart';

import 'package:my24app/member/models/models.dart';

abstract class MemberFetchState extends Equatable {}

class MemberFetchInitialState extends MemberFetchState {
  @override
  List<Object> get props => [];
}

class MemberFetchLoadingState extends MemberFetchState {
  @override
  List<Object> get props => [];
}

class MemberFetchLoadedState extends MemberFetchState {
  final MemberPublic member;

  MemberFetchLoadedState({this.member});

  @override
  List<Object> get props => [member];
}

class MembersFetchLoadedState extends MemberFetchState {
  final Members members;

  MembersFetchLoadedState({this.members});

  @override
  List<Object> get props => [members];
}

class MemberFetchErrorState extends MemberFetchState {
  final String message;

  MemberFetchErrorState({this.message});

  @override
  List<Object> get props => [message];
}
