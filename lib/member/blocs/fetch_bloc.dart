import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/member/api/member_api.dart';
import 'package:my24app/member/models/models.dart';

enum EventStatus { FETCH_MEMBER, FETCH_MEMBERS }

class FetchMemberEvent {
  final EventStatus status;
  final int value;

  const FetchMemberEvent({this.value, this.status});
}

class FetchMemberState extends Equatable {
  final MemberPublic member;
  final Members members;
  final bool hasError;
  final String errorMessage;

  FetchMemberState({this.member, this.members, this.hasError, this.errorMessage});

  @override
  List<Object> get props => [];
}

class FetchMemberBloc extends Bloc<FetchMemberEvent, FetchMemberState> {
  FetchMemberBloc() : super(FetchMemberState());

  @override
  Stream<FetchMemberState> mapEventToState(event) async* {
    if (event.status == EventStatus.FETCH_MEMBER) {
      final result = await _getMember(event.value);
      yield result;
    }
    if (event.status == EventStatus.FETCH_MEMBERS) {
      final result = await _getMembers();
      yield result;
    }
  }

  Future<FetchMemberState> _getMember(int memberPk) async {
    try {
      final MemberPublic result = await memberApi.fetchMember(memberPk);
      return FetchMemberState(member: result, hasError: false);
    } catch(e) {
      return FetchMemberState(hasError: true, errorMessage: e.toString());
    }
  }

  Future<FetchMemberState> _getMembers() async {
    try {
      final Members result = await memberApi.fetchMembers();
      return FetchMemberState(members: result, hasError: false);
    } catch(e) {
      return FetchMemberState(hasError: true, errorMessage: e.toString());
    }
  }
}
