import 'package:http/http.dart' as http;
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24_flutter_member_models/public/models.dart';

import 'fixtures.dart';
import 'http_client.mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch member with error', () async {
    final client = MockClient();
    final fetchMemberBloc = FetchMemberBloc();
    fetchMemberBloc.detailApi.httpClient = client;
    fetchMemberBloc.listApi.httpClient = client;

    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

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
        FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBER, pk: 1));
  });

  test('Test fetch member without error', () async {
    final client = MockClient();
    final fetchMemberBloc = FetchMemberBloc();
    fetchMemberBloc.detailApi.httpClient = client;
    fetchMemberBloc.listApi.httpClient = client;

    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return member data with a 200
    final String memberData = '{"id": 2, "name": "Test", "address": "Teststraat 12", "postal": "034798"}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/member/detail-public/2/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(memberData, 200));

    fetchMemberBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<MemberFetchLoadedState>());
        expect(event.props[0], isA<Member>());
      })
    );

    expectLater(fetchMemberBloc.stream, emits(isA<MemberFetchLoadedState>()));

    fetchMemberBloc.add(
        FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBER, pk: 2));
  });

  test('Test fetch members', () async {
    final client = MockClient();
    final fetchMemberBloc = FetchMemberBloc();
    fetchMemberBloc.listApi.httpClient = client;
    fetchMemberBloc.detailApi.httpClient = client;

    fetchMemberBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<MembersFetchLoadedState>());
        expect(event.props[0], isA<Members>());
      })
    );

    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return members with a 200
    final String memberData = '{"count": 6, "next": null, "previous": null,"results": [{"id": 1, "name": "Test", "address": "Teststraat 12", "postal": "034798"}]}';
    when(client.get(Uri.parse('https://demo.my24service-dev.com/api/member/list-public/'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(memberData, 200));

    expectLater(fetchMemberBloc.stream, emits(isA<MembersFetchLoadedState>()));

    fetchMemberBloc.add(
        FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBERS));
  });
}
