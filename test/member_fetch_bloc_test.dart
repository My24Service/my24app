import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:test/test.dart';

import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24app/member/models/models.dart';

void main() async {
  test('Test fetch member with error', () async {
    final fetchMemberBloc = FetchMemberBloc(MemberFetchInitialState());

    fetchMemberBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<MemberFetchErrorState>());
      })
    );

    expectLater(fetchMemberBloc.stream, emits(isA<MemberFetchErrorState>()));

    fetchMemberBloc.add(
        FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBER, value: 1));
  });

  test('Test fetch member without error', () async {
    final fetchMemberBloc = FetchMemberBloc(MemberFetchInitialState());

    fetchMemberBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<MemberFetchLoadedState>());
      })
    );

    expectLater(fetchMemberBloc.stream, emits(isA<MemberFetchLoadedState>()));

    fetchMemberBloc.add(
        FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBER, value: 2));
  });

  test('Test fetch members', () async {
    final fetchMemberBloc = FetchMemberBloc(MemberFetchInitialState());

    fetchMemberBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<MembersFetchLoadedState>());
      })
    );

    expectLater(fetchMemberBloc.stream, emits(isA<MembersFetchLoadedState>()));

    fetchMemberBloc.add(
        FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBERS));
  });
}
