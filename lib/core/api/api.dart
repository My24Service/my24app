import 'dart:convert';
import 'dart:io' show Platform;

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/models.dart';

mixin ApiMixin {
  Map<String, String> getHeaders(String? token) {
    return {'Authorization': 'Bearer $token'};
  }

  Future<bool?> storeLastPosition(http.Client _httpClient) async {
    // get best latest position
    final Map<String, String> envVars = Platform.environment;

    if (envVars['TESTING'] != null) {
      return null;
    }

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    Position position = await Geolocator.getCurrentPosition();

    final int? userId = _prefs.getInt('user_id');
    final String? token = _prefs.getString('token');
    final url = await getUrl('/company/engineer/$userId/store_lon_lat/');

    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(getHeaders(token));

    final Map body = {
      'lon': position.longitude,
      'lat': position.latitude,
      'speed': position.speed,
      'heading': position.heading,
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool?> postDeviceToken(http.Client _httpClient) async {
    final Map<String, String> envVars = Platform.environment;

    if (envVars['TESTING'] != null) {
      return null;
    }

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    final String? token = _prefs.getString('token');
    final int? userId = _prefs.getInt('user_id');
    final bool? isAllowed = _prefs.getBool('fcm_allowed')!;

    if (!isAllowed!) {
      return false;
    }

    final url = await getUrl('/company/user-device-token/');

    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(getHeaders(token));

    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? messagingToken = await messaging.getToken();

    final Map body = {
      "user": userId,
      "device_token": messagingToken
    };

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<SlidingToken?> refreshSlidingToken(http.Client httpClient) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    final url = await getUrl('/jwt-token/refresh/');
    final token = _prefs.getString('token');
    final authHeaders = getHeaders(token);
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(authHeaders);

    final response = await httpClient.post(
      Uri.parse(url),
      body: json.encode(<String, String?>{"token": token}),
      headers: allHeaders,
    );

    if (response.statusCode == 401) {
      return null;
    }

    if (response.statusCode == 200) {
      SlidingToken token = SlidingToken.fromJson(json.decode(response.body));
      // token.checkIsTokenExpired();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token.token!);

      return token;
    }

    return null;
  }

  Future<int> getPageSize() async {
    final prefs = await SharedPreferences.getInstance();
    int? pageSize = prefs.getInt('pageSize');
    if (pageSize == null) {
      return 20;
    }

    return pageSize;
  }

  Future<String> getUrl(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    String? companycode = prefs.getString('companycode');
    String? apiBaseUrl = prefs.getString('apiBaseUrl');

    if (companycode == null || companycode == '') {
      companycode = 'demo';
    }

    if (apiBaseUrl == null || apiBaseUrl == '') {
      apiBaseUrl = 'my24service-dev.com';
    }

    return 'https://$companycode.$apiBaseUrl/api$path';
  }

  Future<String> getBaseUrlPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? companycode = prefs.getString('companycode');
    String? apiBaseUrl = prefs.getString('apiBaseUrl');

    if (companycode == null || companycode == '') {
      companycode = 'demo';
    }

    if (apiBaseUrl == null || apiBaseUrl == '') {
      apiBaseUrl = 'my24service-dev.com';
    }

    return 'https://$companycode.$apiBaseUrl';
  }
}
