import 'package:equatable/equatable.dart';

import 'package:my24_flutter_member_models/public/models.dart';

import 'package:my24app/company/models/models.dart';

abstract class HomeBaseState extends Equatable {}

class HomeState extends HomeBaseState {
  final BaseUser? user;
  final Member? member;

  HomeState({
    required this.user,
    required this.member,
  });

  @override
  List<Object?> get props => [user, member];
}

class HomeInitialState extends HomeBaseState {
  @override
  List<Object> get props => [];
}

class HomeSoonState extends HomeBaseState {
  final BaseUser? user;
  final Member? member;

  HomeSoonState({
    required this.user,
    required this.member,
  });

  @override
  List<Object> get props => [];
}

class HomeLoggedInState extends HomeBaseState {
  final BaseUser? user;
  final Member member;

  HomeLoggedInState({
    required this.user,
    required this.member,
  });

  @override
  List<Object?> get props => [user, member];
}

class HomeLoginErrorState extends HomeBaseState {
  final String error;
  final Member? member;

  HomeLoginErrorState({
    required this.error,
    required this.member
  });

  @override
  List<Object> get props => [error];
}

class HomeLoadingState extends HomeBaseState {
  @override
  List<Object> get props => [];
}

class HomeDoLoginState extends HomeBaseState {
  final String companycode;
  final String userName;
  final String password;

  HomeDoLoginState({
    required this.companycode,
    required this.userName,
    required this.password
  });

  @override
  List<Object> get props => [companycode, userName, password];
}

class HomeMemberClearedState extends HomeBaseState {
  HomeMemberClearedState();

  @override
  List<Object> get props => [];
}
