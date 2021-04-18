import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/models/models.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test fetch all materials for an assigned order', () async {
    final client = MockClient();
    final materialBloc = MaterialBloc(MaterialInitialState());
    materialBloc.localMobileApi.httpClient = client;
    materialBloc.localMobileApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return material data with a 200
    final String materialData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "assignedOrderId": 1, "material": 1, "location": 1}]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/mobile/assignedordermaterial/?assigned_order=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(materialData, 200));

    materialBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<MaterialsLoadedState>());
        expect(event.props[0], isA<AssignedOrderMaterials>());
      })
    );

    expectLater(materialBloc.stream, emits(isA<MaterialsLoadedState>()));

    materialBloc.add(
        MaterialEvent(
            status: MaterialEventStatus.FETCH_ALL,
            value: 1
        )
    );
  });

  test('Test material insert', () async {
    final client = MockClient();
    final materialBloc = MaterialBloc(MaterialInitialState());
    materialBloc.localMobileApi.httpClient = client;
    materialBloc.localMobileApi.localUtils.httpClient = client;

    AssignedOrderMaterial material = AssignedOrderMaterial(
      assignedOrderId: 1,
      material: 1,
      location: 1,
      materialName: 'test',
      materialIdentifier: 'test',
      amount: 3
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return material data with a 200
    final String materialData = '{"id": 1, "name": "1020", "description": "13948"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/mobile/assignedordermaterial/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(materialData, 201));

    materialBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<MaterialInsertedState>());
          expect(event.props[0], isA<AssignedOrderMaterial>());
        })
    );

    expectLater(materialBloc.stream, emits(isA<MaterialInsertedState>()));

    materialBloc.add(
        MaterialEvent(
            status: MaterialEventStatus.INSERT,
            material: material,
            value: 1
        )
    );
  });

  test('Test material delete', () async {
    final client = MockClient();
    final materialBloc = MaterialBloc(MaterialInitialState());
    materialBloc.localMobileApi.httpClient = client;
    materialBloc.localMobileApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return document delete result with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/mobile/assignedordermaterial/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    materialBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<MaterialDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(materialBloc.stream, emits(isA<MaterialDeletedState>()));

    materialBloc.add(
        MaterialEvent(
            status: MaterialEventStatus.DELETE,
            value: 1
        )
    );
  });

}
