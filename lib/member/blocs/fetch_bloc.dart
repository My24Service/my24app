import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/member/models/public/api.dart';
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:my24app/member/models/public/models.dart';

enum MemberEventStatus {
  FETCH_MEMBER,
  FETCH_MEMBERS,
}

class FetchMemberEvent {
  final MemberEventStatus status;
  final int pk;

  const FetchMemberEvent({this.pk, this.status});
}

class FetchMemberBloc extends Bloc<FetchMemberEvent, MemberFetchState> {
  MemberListPublicApi listApi = MemberListPublicApi();
  MemberDetailPublicApi detailApi = MemberDetailPublicApi();

  FetchMemberBloc() : super(MemberFetchInitialState()) {
    on<FetchMemberEvent>((event, emit) async {
      if (event.status == MemberEventStatus.FETCH_MEMBER) {
        await _handleFetchMemberState(event, emit);
      }
      if (event.status == MemberEventStatus.FETCH_MEMBERS) {
        await _handleFetchMembersState(event, emit);
      }
    },
    transformer: sequential());
  }

  Future<void> _handleFetchMemberState(FetchMemberEvent event, Emitter<MemberFetchState> emit) async {
    try {
      final Member result = await detailApi.detail(event.pk);
      emit(MemberFetchLoadedState(member: result));
    } catch (e) {
      emit(MemberFetchErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchMembersState(FetchMemberEvent event, Emitter<MemberFetchState> emit) async {
    try {
      final Members result = await listApi.list(needsAuth: false);
      emit(MembersFetchLoadedState(members: result));
    } catch(e) {
      emit(MemberFetchErrorState(message: e.toString()));
    }
  }
}
