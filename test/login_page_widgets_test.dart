import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/dev_logging.dart';
import 'package:my24_flutter_member_models/public/models.dart';
import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/common/utils.dart';
import 'package:my24app/home/blocs/home_bloc.dart';
import 'package:my24app/home/blocs/home_states.dart';
import 'package:my24app/home/pages/login.dart';
import 'package:my24app/home/widgets/login.dart';
import 'fixtures.dart';

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
  setUp(() async {
    // TODO this fails the tests, figure out why
    // SharedPreferences.setMockInitialValues({
    //   'token': "",
    //   'companycode': "",
    //   'userInfoData': "",
    //   'memberData': ""
    // });
  });

  tearDown(() async {
    await utils.logout();
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setUpLogging();

  testWidgets('loads login page', (tester) async {
    final client = MockClient();
    final HomeBloc bloc = HomeBloc();
    bloc.utils.httpClient = client;
    bloc.coreUtils.httpClient = client;

    LoginPage page = LoginPage(
      bloc: bloc,
      languageCode: 'nl',
      isLoggedIn: false,
    );

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
            headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response("", 400));

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: page))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CompanyLogo), findsNothing);
    expect(find.byType(My24Logo), findsOneWidget);
    expect(find.byType(LoginButtons), findsOneWidget);
  });

  testWidgets('loads login page logged in', (tester) async {
    final client = MockClient();
    final HomeBloc bloc = HomeBloc();
    bloc.utils.httpClient = client;
    bloc.coreUtils.httpClient = client;
    bloc.utils.memberByCompanycodeApi.httpClient = client;
    final Member demoMember = Member.fromJson(json.decode(memberPublic));

    SharedPreferences.setMockInitialValues({
      'companycode': 'demo',
      'memberData': memberPublic,
    });

    LoginPage page = LoginPage(
      bloc: bloc,
      languageCode: 'nl',
      memberFromHome: demoMember,
      isLoggedIn: true,
    );
    page.coreUtils.httpClient = client;
    page.utils.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(planningUser, 200));

    // member info public
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/member/detail-public-companycode/demo/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(memberPublic, 200));

    // initial data
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/get-initial-data/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(initialData, 200));

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: page))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CompanyLogo), findsOneWidget);
    expect(find.byType(My24Logo), findsNothing);
    expect(find.byType(LoginButtons), findsNothing);
  });

  testWidgets('loads login page with member from home', (tester) async {
    final client = MockClient();
    final HomeBloc bloc = HomeBloc();
    bloc.utils.httpClient = client;
    bloc.coreUtils.httpClient = client;
    final Member demoMember = Member.fromJson(json.decode(memberPublic));

    LoginPage page = LoginPage(
      bloc: bloc,
      memberFromHome: demoMember,
      languageCode: 'nl',
      isLoggedIn: false,
    );

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response("{}", 400));

    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response("", 400));

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: page))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CompanyLogo), findsOneWidget);
    expect(find.byType(My24Logo), findsNothing);
    expect(find.byType(LoginButtons), findsOneWidget);
  });

  testWidgets('does login successful', (tester) async {
    final client = MockClient();
    final HomeBloc bloc = HomeBloc();

    // return login request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // user info
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(planningUser, 200));

    // member info public
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/member/detail-public-companycode/demo/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(memberPublic, 200));

    // initial data
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/get-initial-data/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(initialData, 200));

    bloc.utils.httpClient = client;
    bloc.coreUtils.httpClient = client;
    bloc.utils.memberByCompanycodeApi.httpClient = client;

    final HomeDoLoginState loginState = HomeDoLoginState(
        companycode: "demo",
        userName: "hoi",
        password: "test"
    );

    LoginPage page = LoginPage(
      bloc: bloc,
      initialMode: "login",
      loginState: loginState,
      languageCode: 'nl',
      isLoggedIn: false,
    );

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: page))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CompanyLogo), findsOneWidget);
    expect(find.byType(My24Logo), findsNothing);
    expect(find.byType(LoginButtons), findsNothing);

  });

  testWidgets('does login successful customer user', (tester) async {
    final client = MockClient();
    final HomeBloc bloc = HomeBloc();

    // return login request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // user info
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(customerUser, 200));

    // member info public
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/member/detail-public-companycode/demo/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(memberPublic, 200));

    // initial data
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/get-initial-data/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(initialData, 200));

    bloc.utils.httpClient = client;
    bloc.coreUtils.httpClient = client;
    bloc.utils.memberByCompanycodeApi.httpClient = client;

    final HomeDoLoginState loginState = HomeDoLoginState(
        companycode: "demo",
        userName: "hoi",
        password: "test"
    );

    LoginPage page = LoginPage(
      bloc: bloc,
      initialMode: "login",
      loginState: loginState,
      languageCode: 'nl',
      isLoggedIn: false,
    );

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: page))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CompanyLogo), findsOneWidget);
    expect(find.byType(My24Logo), findsNothing);
    expect(find.byType(LoginButtons), findsNothing);

  });

  testWidgets('login user error', (tester) async {
    final client = MockClient();
    final HomeBloc bloc = HomeBloc();

    // return login request with a 400
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response("{}", 400));

    // return token request with a 400
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 400));

    // user info
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response("", 401));

    // member info public
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/member/detail-public-companycode/demo/'),
          headers: anyNamed('headers'),
        )
    ).thenAnswer((_) async => http.Response(memberPublic, 200));

    bloc.utils.httpClient = client;
    bloc.coreUtils.httpClient = client;
    bloc.utils.memberByCompanycodeApi.httpClient = client;

    final HomeDoLoginState loginState = HomeDoLoginState(
        companycode: "demo",
        userName: "hoi",
        password: "test"
    );

    LoginPage page = LoginPage(
      bloc: bloc,
      initialMode: "login",
      loginState: loginState,
      languageCode: 'nl',
      isLoggedIn: false,
    );
    page.coreUtils.httpClient = client;

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: page))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(CompanyLogo), findsOneWidget);
    expect(find.byType(My24Logo), findsNothing);
    expect(find.byType(LoginButtons), findsOneWidget);
  });

  // testWidgets('loads login page logged in, with equipment uuid', (tester) async {
  //   final client = MockClient();
  //   final HomeBloc bloc = HomeBloc();
  //   bloc.utils.httpClient = client;
  //   bloc.coreUtils.httpClient = client;
  //   bloc.utils.memberByCompanycodeApi.httpClient = client;
  //
  //   final EquipmentBloc equipmentBloc = EquipmentBloc();
  //   equipmentBloc.orderApi.httpClient = client;
  //   equipmentBloc.equipmentApi.httpClient = client;
  //
  //   SharedPreferences.setMockInitialValues({
  //     'companycode': 'demo',
  //     'memberData': memberPublic,
  //
  //   });
  //
  //   LoginPage page = LoginPage(
  //     bloc: bloc,
  //     languageCode: 'nl',
  //     equipmentUuid: "c56ddfe1-f51b-4045-9d85-776e8ab0dcd4",
  //     equipmentBloc: equipmentBloc,
  //   );
  //
  //   // return token request with a 200
  //   when(
  //       client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
  //           headers: anyNamed('headers'),
  //           body: anyNamed('body')
  //       )
  //   ).thenAnswer((_) async => http.Response(tokenData, 200));
  //
  //   when(
  //       client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
  //         headers: anyNamed('headers'),
  //       )
  //   ).thenAnswer((_) async => http.Response(planningUser, 200));
  //
  //   // member info public
  //   when(
  //       client.get(Uri.parse('https://demo.my24service-dev.com/api/member/detail-public-companycode/demo/'),
  //         headers: anyNamed('headers'),
  //       )
  //   ).thenAnswer((_) async => http.Response(memberPublic, 200));
  //
  //   // initial data
  //   when(
  //       client.get(Uri.parse('https://demo.my24service-dev.com/api/get-initial-data/'),
  //         headers: anyNamed('headers'),
  //       )
  //   ).thenAnswer((_) async => http.Response(initialData, 200));
  //
  //   // return orders data with a 200
  //   when(client.get(
  //       Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_equipment_location/?equipment=1'),
  //       headers: anyNamed('headers')))
  //       .thenAnswer((_) async => http.Response(ordersEmpty, 200));
  //
  //   // return equipment data with a 200
  //   when(client.get(Uri.parse(
  //       'https://demo.my24service-dev.com/api/equipment/equipment/c56ddfe1-f51b-4045-9d85-776e8ab0dcd4/uuid/'),
  //       headers: anyNamed('headers')))
  //       .thenAnswer((_) async => http.Response(equipment, 200));
  //
  //   await mockNetworkImagesFor(() async => await tester.pumpWidget(
  //       createWidget(child: page))
  //   );
  //   await mockNetworkImagesFor(() async => await tester.pumpAndSettle());
  //
  //   expect(find.byType(EquipmentDetailPage), findsOneWidget);
  //   expect(find.byType(CompanyLogo), findsNothing);
  //   expect(find.byType(ShltrLogo), findsNothing);
  //   expect(find.byType(LoginButtons), findsNothing);
  // });
  //
  // testWidgets('loads login page not logged in, with equipment uuid', (tester) async {
  //   final client = MockClient();
  //   final HomeBloc bloc = HomeBloc();
  //   bloc.utils.httpClient = client;
  //   bloc.coreUtils.httpClient = client;
  //   bloc.utils.memberByCompanycodeApi.httpClient = client;
  //
  //   final EquipmentBloc equipmentBloc = EquipmentBloc();
  //   equipmentBloc.orderApi.httpClient = client;
  //   equipmentBloc.equipmentApi.httpClient = client;
  //
  //   SharedPreferences.setMockInitialValues({
  //     'companycode': 'demo',
  //     'memberData': memberPublic,
  //
  //   });
  //
  //   LoginPage page = LoginPage(
  //     bloc: bloc,
  //     languageCode: 'nl',
  //     equipmentUuid: "c56ddfe1-f51b-4045-9d85-776e8ab0dcd4",
  //     equipmentBloc: equipmentBloc,
  //   );
  //
  //   // return 400
  //   when(
  //       client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
  //           headers: anyNamed('headers'),
  //           body: anyNamed('body')
  //       )
  //   ).thenAnswer((_) async => http.Response("{}", 400));
  //
  //   when(
  //       client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
  //         headers: anyNamed('headers'),
  //       )
  //   ).thenAnswer((_) async => http.Response("{}", 400));
  //
  //   // member info public
  //   when(
  //       client.get(Uri.parse('https://demo.my24service-dev.com/api/member/detail-public-companycode/demo/'),
  //         headers: anyNamed('headers'),
  //       )
  //   ).thenAnswer((_) async => http.Response(memberPublic, 200));
  //
  //   // initial data
  //   when(
  //       client.get(Uri.parse('https://demo.my24service-dev.com/api/get-initial-data/'),
  //         headers: anyNamed('headers'),
  //       )
  //   ).thenAnswer((_) async => http.Response(initialData, 200));
  //
  //   await mockNetworkImagesFor(() async => await tester.pumpWidget(
  //       createWidget(child: page))
  //   );
  //   await mockNetworkImagesFor(() async => await tester.pumpAndSettle());
  //
  //   expect(find.byType(CompanyLogo), findsOneWidget);
  //   expect(find.byType(LoginButtons), findsOneWidget);
  //   expect(find.byType(EquipmentNotice), findsOneWidget);
  //   expect(find.byType(EquipmentDetailPage), findsNothing);
  //   expect(find.byType(ShltrLogo), findsNothing);
  // });
  //
  // testWidgets('does login successful with equipment uuid', (tester) async {
  //   final client = MockClient();
  //   final HomeBloc bloc = HomeBloc();
  //
  //   // return login request with a 200
  //   when(
  //       client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/'),
  //           headers: anyNamed('headers'),
  //           body: anyNamed('body')
  //       )
  //   ).thenAnswer((_) async => http.Response(tokenData, 200));
  //
  //   // return token request with a 200
  //   when(
  //       client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
  //           headers: anyNamed('headers'),
  //           body: anyNamed('body')
  //       )
  //   ).thenAnswer((_) async => http.Response(tokenData, 200));
  //
  //   // user info
  //   when(
  //       client.get(Uri.parse('https://demo.my24service-dev.com/api/company/user-info-me/'),
  //         headers: anyNamed('headers'),
  //       )
  //   ).thenAnswer((_) async => http.Response(planningUser, 200));
  //
  //   // member info public
  //   when(
  //       client.get(Uri.parse('https://demo.my24service-dev.com/api/member/detail-public-companycode/demo/'),
  //         headers: anyNamed('headers'),
  //       )
  //   ).thenAnswer((_) async => http.Response(memberPublic, 200));
  //
  //   // initial data
  //   when(
  //       client.get(Uri.parse('https://demo.my24service-dev.com/api/get-initial-data/'),
  //         headers: anyNamed('headers'),
  //       )
  //   ).thenAnswer((_) async => http.Response(initialData, 200));
  //
  //   // return orders data with a 200
  //   when(client.get(
  //       Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_equipment_location/?equipment=1'),
  //       headers: anyNamed('headers')))
  //       .thenAnswer((_) async => http.Response(ordersEmpty, 200));
  //
  //   // return equipment data with a 200
  //   when(client.get(Uri.parse(
  //       'https://demo.my24service-dev.com/api/equipment/equipment/c56ddfe1-f51b-4045-9d85-776e8ab0dcd4/uuid/'),
  //       headers: anyNamed('headers')))
  //       .thenAnswer((_) async => http.Response(equipment, 200));
  //
  //   bloc.utils.httpClient = client;
  //   bloc.coreUtils.httpClient = client;
  //   bloc.utils.memberByCompanycodeApi.httpClient = client;
  //
  //   final EquipmentBloc equipmentBloc = EquipmentBloc();
  //   equipmentBloc.orderApi.httpClient = client;
  //   equipmentBloc.equipmentApi.httpClient = client;
  //
  //   final HomeDoLoginState loginState = HomeDoLoginState(
  //       companycode: "demo",
  //       userName: "hoi",
  //       password: "test"
  //   );
  //
  //   LoginPage page = LoginPage(
  //     bloc: bloc,
  //     initialMode: "login",
  //     loginState: loginState,
  //     languageCode: 'nl',
  //     equipmentUuid: "c56ddfe1-f51b-4045-9d85-776e8ab0dcd4",
  //     equipmentBloc: equipmentBloc,
  //   );
  //
  //   await mockNetworkImagesFor(() async => await tester.pumpWidget(
  //       createWidget(child: page))
  //   );
  //   await mockNetworkImagesFor(() async => await tester.pumpAndSettle());
  //
  //   expect(find.byType(EquipmentDetailPage), findsOneWidget);
  //   expect(find.byType(CompanyLogo), findsNothing);
  //   expect(find.byType(ShltrLogo), findsNothing);
  //   expect(find.byType(LoginButtons), findsNothing);
  // });
}
