import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';

import 'package:my24app/mobile/pages/assign.dart';
import 'package:my24app/mobile/widgets/assign.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my24app/mobile/blocs/assign_bloc.dart';
import 'fixtures.dart';
import 'http_client.mocks.dart';

Widget createWidget({Widget? child}) {
  return MaterialApp(
      home: Scaffold(
          body: Container(
              child: child
          )
      ),
  );
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('loads list', (tester) async {
    final client = MockClient();
    final assignBloc = AssignBloc();
    assignBloc.localMobileApi.httpClient = client;
    assignBloc.localOrderApi.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return order data with a 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/order/order/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(order, 200));

    final String engineers = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": [$engineerUser]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/engineer/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(engineers, 200));

    OrderAssignPage widget = OrderAssignPage(
        bloc: assignBloc,
        orderId: 1,
    );
    widget.companyApi.httpClient = client;
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(AssignWidget), findsOneWidget);
  });
}
