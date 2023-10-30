import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

@GenerateMocks([http.Client])
import 'http_client.mocks.dart';

MockClient client = MockClient();
