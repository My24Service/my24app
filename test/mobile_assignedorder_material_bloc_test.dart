import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/mobile/models/material/form_data.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/models/material/models.dart';
import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all materials for an assigned order', () async {
    final client = MockClient();
    final materialBloc = AssignedOrderMaterialBloc();
    materialBloc.api.httpClient = client;

    // return token request with a 200
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
        AssignedOrderMaterialEvent(
            status: AssignedOrderMaterialEventStatus.FETCH_ALL,
            assignedOrderId: 1
        )
    );
  });

  test('Test material insert', () async {
    final client = MockClient();
    final materialBloc = AssignedOrderMaterialBloc();
    materialBloc.api.httpClient = client;

    AssignedOrderMaterial material = AssignedOrderMaterial(
      assignedOrderId: 1,
      material: 1,
      location: 1,
      materialName: 'test',
      materialIdentifier: 'test',
      amount: 3
    );

    // return token request with a 200
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
    final materialBloc = AssignedOrderMaterialBloc();
    materialBloc.api.httpClient = client;

    // return token request with a 200
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
        AssignedOrderMaterialEvent(
            status: AssignedOrderMaterialEventStatus.DELETE,
            pk: 1
        )
    );
  });

  test('Test material new', () async {
    final materialBloc = AssignedOrderMaterialBloc();

    materialBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<MaterialNewState>());
          expect(event.props[0], isA<AssignedOrderMaterialFormData>());
        })
    );

    materialBloc.add(
        AssignedOrderMaterialEvent(
            status: AssignedOrderMaterialEventStatus.NEW,
            assignedOrderId: 1
        )
    );
  });

  test('Test material new with quotation', () async {
    final materialBloc = AssignedOrderMaterialBloc();
    final client = MockClient();
    materialBloc.api.httpClient = client;
    materialBloc.quotationApi.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return quotation materials
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/quotation/quotation/1/get_materials_for_app/'),
            headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(quotationMaterials, 200));

    // return entered quotation materials
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/mobile/assignedordermaterial/quotation/?quotation=1'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(enteredMaterialsFromQuotation, 200));

    materialBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<MaterialNewState>());
          expect(event.props[0], isA<AssignedOrderMaterialFormData>());
        })
    );

    materialBloc.add(
        AssignedOrderMaterialEvent(
            status: AssignedOrderMaterialEventStatus.NEW,
            assignedOrderId: 1,
            quotationId: 1
        )
    );
  });
}
