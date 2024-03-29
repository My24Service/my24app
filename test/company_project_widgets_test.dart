import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/company/pages/project.dart';
import 'package:my24app/company/widgets/project/form.dart';
import 'package:my24app/company/widgets/project/error.dart';
import 'package:my24app/company/widgets/project/list.dart';
import 'package:my24app/company/blocs/project_bloc.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('finds list', (tester) async {
    final client = MockClient();
    final projectBloc = ProjectBloc();

    projectBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return project data with a 200
    final String projectsData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": [$projectData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/project/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(projectsData, 200));

    ProjectPage widget = ProjectPage(bloc: projectBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(ProjectFormWidget), findsNothing);
    expect(find.byType(ProjectListErrorWidget), findsNothing);
    expect(find.byType(ProjectListWidget), findsOneWidget);
  });

  testWidgets('finds empty', (tester) async {
    final client = MockClient();
    final projectBloc = ProjectBloc();
    projectBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return project data with a 200
    final String projectsData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/project/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(projectsData, 200));

    ProjectPage widget = ProjectPage(bloc: projectBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(ProjectFormWidget), findsOneWidget);
    expect(find.byType(ProjectListErrorWidget), findsNothing);
    expect(find.byType(ProjectListWidget), findsNothing);
  });

  testWidgets('finds error', (tester) async {
    final client = MockClient();
    final projectBloc = ProjectBloc();
    projectBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return project data with a 500
    final String projectsData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": []}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/project/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(projectsData, 500));

    ProjectPage widget = ProjectPage(bloc: projectBloc);
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(ProjectFormWidget), findsNothing);
    expect(find.byType(ProjectListErrorWidget), findsOneWidget);
    expect(find.byType(ProjectListWidget), findsNothing);
  });

  testWidgets('finds form edit', (tester) async {
    final client = MockClient();
    final projectBloc = ProjectBloc();
    projectBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return project data with 200
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/project/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(projectData, 200));

    ProjectPage widget = ProjectPage(
      bloc: projectBloc,
      initialMode: 'form',
      pk: 1,
    );
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(ProjectListErrorWidget), findsNothing);
    expect(find.byType(ProjectListWidget), findsNothing);
    expect(find.byType(ProjectFormWidget), findsOneWidget);
  });

  testWidgets('finds form new', (tester) async {
    final client = MockClient();
    final projectBloc = ProjectBloc();
    projectBloc.api.httpClient = client;

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    ProjectPage widget = ProjectPage(
      bloc: projectBloc,
      initialMode: 'new'
    );
    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(ProjectListErrorWidget), findsNothing);
    expect(find.byType(ProjectListWidget), findsNothing);
    expect(find.byType(ProjectFormWidget), findsOneWidget);
  });
}
