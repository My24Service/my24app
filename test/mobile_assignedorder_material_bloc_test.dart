import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/models/material/models.dart';
import 'fixtures.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all materials for an assigned order', () async {
    final client = MockClient();
    final materialBloc = MaterialBloc();
    materialBloc.api.httpClient = client;
    materialBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return material data with a 200
    final String materialData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": [$assignedOrderMaterial]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedordermaterial/?assigned_order=1'),
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
            assignedOrderId: 1
        )
    );
  });

  test('Test material insert', () async {
    final client = MockClient();
    final materialBloc = MaterialBloc();
    materialBloc.api.httpClient = client;
    materialBloc.api.localUtils.httpClient = client;

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
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return material data with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedordermaterial/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(assignedOrderMaterial, 201));

    final AssignedOrderMaterial newMaterial = await materialBloc.api.insert(material);
    expect(newMaterial, isA<AssignedOrderMaterial>());
  });

  test('Test material delete', () async {
    final client = MockClient();
    final materialBloc = MaterialBloc();
    materialBloc.api.httpClient = client;
    materialBloc.api.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return material delete result with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedordermaterial/1/'),
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
            pk: 1
        )
    );
  });

}
