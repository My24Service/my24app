import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/quotation/blocs/image_bloc.dart';
import 'package:my24app/quotation/blocs/image_states.dart';
import 'package:my24app/quotation/models/models.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all images for a quotation', () async {
    final client = MockClient();
    final imageBloc = ImageBloc();
    imageBloc.localQuotationApi.httpClient = client;
    imageBloc.localQuotationApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return quotation image data with a 200
    final String quotationData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [{"id": 1, "name": "1020", "description": "test test"}]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/quotation/quotation-image/?quotation=1'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(quotationData, 200));

    imageBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<ImagesLoadedState>());
        expect(event.props[0], isA<QuotationImages>());
      })
    );

    expectLater(imageBloc.stream, emits(isA<ImagesLoadedState>()));

    imageBloc.add(
        ImageEvent(
            status: ImageEventStatus.FETCH_ALL,
            quotationPk: 1
        )
    );
  });

  test('Test quotation insert', () async {
    final client = MockClient();
    final imageBloc = ImageBloc();
    imageBloc.localQuotationApi.httpClient = client;
    imageBloc.localQuotationApi.localUtils.httpClient = client;

    QuotationImage image = QuotationImage(
      image: 'test',
      description: 'test 1',
    );

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return quotation data with a 201
    final String quotationData = '{"id": 1, "name": "1020", "description": "13948"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/quotation/quotation-image/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(quotationData, 201));

    final QuotationImage newImage = await imageBloc.localQuotationApi.insertQuotationImage(image, 1);
    expect(newImage, isA<QuotationImage>());
  });

  test('Test quotation delete', () async {
    final client = MockClient();
    final imageBloc = ImageBloc();
    imageBloc.localQuotationApi.httpClient = client;
    imageBloc.localQuotationApi.localUtils.httpClient = client;

    // return token request with a 200
    final String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return image delete result with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/api/quotation/quotation-image/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    imageBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<ImageDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(imageBloc.stream, emits(isA<ImageDeletedState>()));

    imageBloc.add(
        ImageEvent(
            status: ImageEventStatus.DELETE,
            value: 1
        )
    );
  });
}
