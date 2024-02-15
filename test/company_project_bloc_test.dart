import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24app/company/models/project/form_data.dart';
import 'package:my24app/company/models/project/models.dart';
import 'package:my24app/company/blocs/project_bloc.dart';
import 'package:my24app/company/blocs/project_states.dart';
import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch all projects', () async {
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
    final String projectsData = '{"next": null, "previous": null, "count": 4, "num_pages": 1, "results": [$projectData]}';
    when(
        client.get(Uri.parse('https://demo.my24service-dev.com/api/company/project/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response(projectsData, 200));

    projectBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<ProjectsLoadedState>());
        expect(event.props[0], isA<Projects>());
      })
    );

    expectLater(projectBloc.stream, emits(isA<ProjectsLoadedState>()));

    projectBloc.add(
        ProjectEvent(status: ProjectEventStatus.FETCH_ALL));
  });

  test('Test project delete', () async {
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

    // return no content with a 204
    when(
        client.delete(Uri.parse('https://demo.my24service-dev.com/api/company/project/1/'),
            headers: anyNamed('headers')
        )
    ).thenAnswer((_) async => http.Response('', 204));

    projectBloc.stream.listen(
      expectAsync1((event) {
        expect(event, isA<ProjectDeletedState>());
        expect(event.props[0], true);
      })
    );

    expectLater(projectBloc.stream, emits(isA<ProjectDeletedState>()));

    projectBloc.add(
        ProjectEvent(status: ProjectEventStatus.DELETE, pk: 1));
  });

  test('Test project insert', () async {
    final client = MockClient();
    final projectBloc = ProjectBloc();
    projectBloc.api.httpClient = client;

    Project project = Project(
      name: 'test',
    );

    // return token request with a 200
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(tokenData, 200));

    // return project data with a 201
    when(
        client.post(Uri.parse('https://demo.my24service-dev.com/api/company/project/'),
            headers: anyNamed('headers'),
            body: anyNamed('body')
        )
    ).thenAnswer((_) async => http.Response(projectData, 201));

    final Project newProject = await projectBloc.api.insert(project);
    expect(newProject, isA<Project>());
  });

  test('Test project new', () async {
    final projectBloc = ProjectBloc();

    projectBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<ProjectNewState>());
          expect(event.props[0], isA<ProjectFormData>());
        })
    );

    projectBloc.add(
        ProjectEvent(
            status: ProjectEventStatus.NEW,
        )
    );
  });
}
