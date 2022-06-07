import 'package:http/http.dart' as http;
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24app/member/models/models.dart';

class MockClient extends Mock implements http.Client {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch member with error', () async {
    final client = MockClient();
    final fetchMemberBloc = FetchMemberBloc();
    fetchMemberBloc.localMemberApi.httpClient = client;
    fetchMemberBloc.localMemberApi.localUtils.httpClient = client;

    // return member data with a 404
    final String memberData = '{"detail": "not found"}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/member/detail-public/1/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(memberData, 404));

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
    final client = MockClient();
    final fetchMemberBloc = FetchMemberBloc();
    fetchMemberBloc.localMemberApi.httpClient = client;
    fetchMemberBloc.localMemberApi.localUtils.httpClient = client;

    // return member data with a 200
    final String memberData = '{"id": 2, "name": "Test", "address": "Teststraat 12", "postal": "034798"}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/member/detail-public/2/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(memberData, 200));

    fetchMemberBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<MemberFetchLoadedState>());
        expect(event.props[0], isA<MemberPublic>());
      })
    );

    expectLater(fetchMemberBloc.stream, emits(isA<MemberFetchLoadedState>()));

    fetchMemberBloc.add(
        FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBER, value: 2));
  });

  test('Test fetch members', () async {
    final client = MockClient();
    final fetchMemberBloc = FetchMemberBloc();
    fetchMemberBloc.localMemberApi.httpClient = client;
    fetchMemberBloc.localMemberApi.localUtils.httpClient = client;

    fetchMemberBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<MembersFetchLoadedState>());
        expect(event.props[0], isA<Members>());
      })
    );

    // return members with a 200
    final String memberData = '{"count": 6, "next": null, "previous": null,"results": [{"id": 1, "name": "Test", "address": "Teststraat 12", "postal": "034798"}]}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/member/list-public/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(memberData, 200));

    expectLater(fetchMemberBloc.stream, emits(isA<MembersFetchLoadedState>()));

    fetchMemberBloc.add(
        FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBERS));
  });
}
