import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/assignedorders_list.dart';
import 'package:my24app/models.dart';
import 'fixtures.dart';

class MockClient extends Mock implements http.Client {}

main() {
  group('fetchAssignedOrders', () {
  });
}
