import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/member/api/member_api.dart';
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:my24app/member/models/models.dart';

enum MemberEventStatus { FETCH_MEMBER, FETCH_MEMBERS, FETCH_MEMBER_PREF }

class FetchMemberEvent {
  final MemberEventStatus status;
  final int value;

  const FetchMemberEvent({this.value, this.status});
}

class FetchMemberBloc extends Bloc<FetchMemberEvent, MemberFetchState> {
  FetchMemberBloc(MemberFetchState initialState) : super(initialState);

  @override
  Stream<MemberFetchState> mapEventToState(event) async* {
    if (event.status == MemberEventStatus.FETCH_MEMBER) {
      try {
        final MemberPublic result = await memberApi.fetchMember(event.value);
        yield MemberFetchLoadedState(member: result);
      } catch(e) {
        yield MemberFetchErrorState(message: e.toString());
      }
    }

    if (event.status == MemberEventStatus.FETCH_MEMBER_PREF) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final int memberPk = prefs.getInt('member_pk');
      try {
        final MemberPublic result = await memberApi.fetchMember(memberPk);
        yield MemberFetchLoadedByPrefState(member: result);
      } catch(e) {
        yield MemberFetchErrorState(message: e.toString());
      }
    }

    if (event.status == MemberEventStatus.FETCH_MEMBERS) {
      try {
        final Members result = await memberApi.fetchMembers();
        yield MembersFetchLoadedState(members: result);
      } catch(e) {
        yield MemberFetchErrorState(message: e.toString());
      }
    }
  }
}