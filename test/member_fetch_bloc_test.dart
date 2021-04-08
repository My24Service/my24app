import 'package:test/test.dart';

import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24app/member/models/models.dart';

void main() async {
  test('Test fetch member with error', () async {
    final fetchMemberBloc = FetchMemberBloc();

    fetchMemberBloc.stream.listen(
      expectAsync1((event) {
        expect(event.hasError, true);
      })
    );

    expectLater(fetchMemberBloc.stream, emits(isA<FetchMemberState>()));

    fetchMemberBloc.add(
        FetchMemberEvent(status: EventStatus.FETCH_MEMBER, value: 1));
  });

  test('Test fetch member without error', () async {
    final fetchMemberBloc = FetchMemberBloc();

    fetchMemberBloc.stream.listen(
      expectAsync1((event) {
        expect(event.hasError, false);
        expect(event.member is MemberPublic, true);
      })
    );

    expectLater(fetchMemberBloc.stream, emits(isA<FetchMemberState>()));

    fetchMemberBloc.add(
        FetchMemberEvent(status: EventStatus.FETCH_MEMBER, value: 2));
  });

  test('Test fetch members', () async {
    final fetchMemberBloc = FetchMemberBloc();

    fetchMemberBloc.stream.listen(
      expectAsync1((event) {
        expect(event.hasError, false);
        expect(event.members is Members, true);
      })
    );

    expectLater(fetchMemberBloc.stream, emits(isA<FetchMemberState>()));

    fetchMemberBloc.add(
        FetchMemberEvent(status: EventStatus.FETCH_MEMBERS));
  });
}
