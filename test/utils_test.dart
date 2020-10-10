import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import 'package:my24app/utils.dart';
import 'package:my24app/models.dart';


class MockClient extends Mock implements http.Client {}

main() {
  group('refreshToken', () {
  });
}
