import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/company/models/models.dart';

class Utils with ApiMixin {
  SharedPreferences _prefs;

  // default and settable for tests
  http.Client _httpClient = http.Client();
  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Future<String> getBaseUrl() async {
    return getBaseUrlPrefs();
  }

  String formatDate(DateTime date) {
    return "${date.toLocal()}".split(' ')[0];
  }

  String formatTime(DateTime time) {
    return '$time'.split(' ')[1];
  }

  double round(double num) {
    return (num * 100).round() / 100;
  }

  Future<bool> storeLastPosition() async {
    // get best latest position
    final Map<String, String> envVars = Platform.environment;

    if (envVars['TESTING'] != null) {
      return null;
    }

    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    Position position;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    position = await Geolocator.getCurrentPosition();

    if (position == null) {
      print(' no position');
      return false;
    }

    final int userId = _prefs.getInt('user_id');
    final String token = _prefs.getString('token');
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

  Future<bool> postDeviceToken() async {
    final Map<String, String> envVars = Platform.environment;

    if (envVars['TESTING'] != null) {
      return null;
    }

    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    final String token = _prefs.getString('token');
    final int userId = _prefs.getInt('user_id');
    final bool isAllowed = _prefs.getBool('fcm_allowed');

    if (!isAllowed) {
      return false;
    }

    final url = await getUrl('/company/user-device-token/');

    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(getHeaders(token));

    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String messageingToken = await messaging.getToken();

    final Map body = {
      "user": userId,
      "device_token": messageingToken
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

  Future<String> getMemberName() async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    return _prefs.getString('member_name');
  }

  Locale lang2locale(String lang) {
    if (lang == 'nl') {
      return Locale('nl', 'NL');
    }

    if (lang == 'en') {
      return Locale('en', 'US');
    }

    return null;
  }

  Future<bool> isLoggedInSlidingToken() async {
    // refresh token
    SlidingToken newToken = await refreshSlidingToken();

    if(newToken == null) {
      return false;
    }

    return true;
  }

  Future<bool> logout() async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    _prefs.remove('token');

    return true;
  }

  Map<String, String> getHeaders(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  Future<SlidingToken> attemptLogIn(String username, String password) async {
    final url = await getUrl('/jwt-token/');
    final res = await _httpClient.post(
        Uri.parse(url),
        body: {
          "username": username,
          "password": password
        }
    );

    if (res.statusCode == 200) {
      SlidingToken token = SlidingToken.fromJson(json.decode(res.body));
      token.checkIsTokenExpired();

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token.token);

      return token;
    }

    return null;
  }

  Future<dynamic> getUserInfo(int pk) async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    final url = await getUrl('/company/user-info-me/');
    final token = _prefs.getString('token');
    final res = await _httpClient.get(
        Uri.parse(url),
        headers: getHeaders(token)
    );

    if (res.statusCode == 200) {
      var userInfoData = json.decode(res.body);

      // create models based on user type
      if (userInfoData['submodel'] == 'engineer') {
        EngineerUser engineer = EngineerUser.fromJson(userInfoData['user']);
        StreamInfo streamInfo = StreamInfo.fromJson(userInfoData['stream']);

        return {
          'user': engineer,
          'streamInfo': streamInfo
        };
      }

      if (userInfoData['submodel'] == 'customer_user') {
        CustomerUser customerUser = CustomerUser.fromJson(userInfoData['user']);

        return {
          'user': customerUser,
          'streamInfo': Null
        };
      }

      if (userInfoData['submodel'] == 'planning_user') {
        PlanningUser planningUser = PlanningUser.fromJson(userInfoData['user']);
        StreamInfo streamInfo = StreamInfo.fromJson(userInfoData['stream']);

        return {
          'user': planningUser,
          'streamInfo': streamInfo
        };
      }

      if (userInfoData['submodel'] == 'sales_user') {
        SalesUser salesUser = SalesUser.fromJson(userInfoData['user']);
        StreamInfo streamInfo = StreamInfo.fromJson(userInfoData['stream']);

        return {
          'user': salesUser,
          'streamInfo': streamInfo
        };
      }
    }

    return null;
  }

  Future<SlidingToken> refreshSlidingToken() async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    final url = await getUrl('/jwt-token/refresh/');
    final token = _prefs.getString('token');
    final authHeaders = getHeaders(token);
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(authHeaders);

    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(<String, String>{"token": token}),
      headers: allHeaders,
    );

    if (response.statusCode == 401) {
      return null;
    }

    if (response.statusCode == 200) {
      SlidingToken token = SlidingToken.fromJson(json.decode(response.body));
      // token.checkIsTokenExpired();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token.token);

      return token;
    }

    return null;
  }

  Future<String> getUserSubmodel() async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    return _prefs.getString('submodel');
  }

  Future<void> requestFCMPermissions() async {
    // request permissions
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    if (!_prefs.containsKey('fcm_allowed')) {
      bool isAllowed = false;

      if (Platform.isAndroid) {
        isAllowed = true;
      } else {
        await Firebase.initializeApp();
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          sound: true,
          announcement: false,
          badge: false,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
        );

        // are we allowed?
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          isAllowed = true;
        }
      }

      _prefs.setBool('fcm_allowed', isAllowed);

      if (isAllowed) {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');

          if (message.notification != null) {
            print('Message also contained a notification: ${message.notification}');
          }
        });
      }
    }
  }

  Future<String> getOrderListTitleForUser() async {
    String submodel = await getUserSubmodel();

    if (submodel == 'customer_user') {
      return 'orders.list.app_title_customer_user'.tr();
    }

    if (submodel == 'planning_user') {
      return 'orders.list.app_title_planning_user'.tr();
    }

    if (submodel == 'sales_user') {
      return 'orders.list.app_title_sales_user'.tr();
    }

    return null;
  }

  launchURL(String url) async {
    if (url == null || url == '') {
      return;
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

Utils utils = Utils();
