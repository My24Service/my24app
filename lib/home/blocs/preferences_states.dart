import 'package:equatable/equatable.dart';

abstract class HomePreferencesBaseState extends Equatable {}

class HomePreferencesState extends HomePreferencesBaseState {
  final String? languageCode;
  final bool doSkip;
  final int? memberPk;

  HomePreferencesState({
    required this.languageCode,
    required this.doSkip,
    required this.memberPk,
  });

  @override
  List<Object?> get props => [languageCode, doSkip, memberPk];
}

class HomePreferencesInitialState extends HomePreferencesBaseState {
  @override
  List<Object> get props => [];
}
