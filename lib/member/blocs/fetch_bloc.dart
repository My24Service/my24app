import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/member/api/member_api.dart';
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:my24app/member/models/models.dart';

enum MemberEventStatus {
  FETCH_MEMBER,
  FETCH_MEMBERS,
  FETCH_MEMBER_PREF
}

class FetchMemberEvent {
  final MemberEventStatus status;
  final int value;

  const FetchMemberEvent({this.value, this.status});
}

class FetchMemberBloc extends Bloc<FetchMemberEvent, MemberFetchState> {
  MemberApi localMemberApi = memberApi;

  FetchMemberBloc() : super(MemberFetchInitialState()) {
    on<FetchMemberEvent>((event, emit) async {
      if (event.status == MemberEventStatus.FETCH_MEMBER) {
        await _handleFetchMemberState(event, emit);
      }
      if (event.status == MemberEventStatus.FETCH_MEMBERS) {
        await _handleFetchMembersState(event, emit);
      }
      else if (event.status == MemberEventStatus.FETCH_MEMBER_PREF) {
        await _handleMemberPrefState(event, emit);
      }
    },
    transformer: sequential());
  }

  Future<void> _handleFetchMemberState(FetchMemberEvent event, Emitter<MemberFetchState> emit) async {
    try {
      final MemberPublic result = await localMemberApi.fetchMember(event.value);
      emit(MemberFetchLoadedState(member: result));
    } catch (e) {
      emit(MemberFetchErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchMembersState(FetchMemberEvent event, Emitter<MemberFetchState> emit) async {
    try {
      final Members result = await localMemberApi.fetchMembers();
      emit(MembersFetchLoadedState(members: result));
    } catch(e) {
      emit(MemberFetchErrorState(message: e.toString()));
    }
  }

  Future<void> _handleMemberPrefState(FetchMemberEvent event, Emitter<MemberFetchState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int memberPk = prefs.getInt('member_pk');
    try {
      final MemberPublic result = await localMemberApi.fetchMember(memberPk);
      emit(MemberFetchLoadedByPrefState(member: result));
    } catch (e) {
      emit(MemberFetchErrorState(message: e.toString()));
    }
  }
}
