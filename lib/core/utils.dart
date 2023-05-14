import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:io' as io;

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my24app/core/api/api.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/company/models/models.dart';

import '../member/models/models.dart';
import '../company/models/picture/api.dart';
import '../member/models/public/api.dart';
import '../member/models/public/models.dart';

class Utils with ApiMixin {
  SharedPreferences _prefs;
  MemberDetailPublicApi memberApi = MemberDetailPublicApi();
  PicturePublicApi picturePublicApi = PicturePublicApi();

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

  String timeNoSeconds(String time) {
    if (time != null) {
      List parts = time.split(':');
      return "${parts[0]}:${parts[1]}";
    }
    return "-";
  }

  double round(double num) {
    return (num * 100).round() / 100;
  }

  Future<String> getMemberName() async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    return _prefs.getString('member_name');
  }

  Future<Member> fetchMemberPref() async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    final int memberPk = _prefs.getInt('member_pk');
    try {
      final Member result = await memberApi.detail(memberPk, needsAuth: false);
      return result;
    } catch (e) {
      print(e);
      print("Error fetching member public");
    }

    return null;
  }

  Future<MemberDetailData> getMemberDetailData() async {
    MemberDetailData result = MemberDetailData(
      isLoggedIn: await isLoggedInSlidingToken(),
      submodel: await getUserSubmodel(),
      member: await fetchMemberPref()
    );

    return result;
  }

  Future<String> getFirstName() async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    return _prefs.getString('first_name');
  }

  Future<String> getMemberPicture() async {
    return await picturePublicApi.getRandomPicture(httpClientOverride: _httpClient);
  }

  Future<DefaultPageData> getDefaultPageData() async {
    String memberPicture = await getMemberPicture();

    DefaultPageData result = DefaultPageData(
        memberPicture: memberPicture,
    );

    return result;
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
    SlidingToken newToken = await refreshSlidingToken(_httpClient);

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
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    final url = await getUrl('/jwt-token/');
    final res = await _httpClient.post(
        Uri.parse(url),
        body: json.encode({
          "username": username,
          "password": password
        }),
      headers: allHeaders
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

  Future<dynamic> getUserInfo() async {
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

        return {
          'user': engineer,
        };
      }

      if (userInfoData['submodel'] == 'customer_user') {
        CustomerUser customerUser = CustomerUser.fromJson(userInfoData['user']);

        return {
          'user': customerUser,
        };
      }

      if (userInfoData['submodel'] == 'planning_user') {
        PlanningUser planningUser = PlanningUser.fromJson(userInfoData['user']);

        return {
          'user': planningUser,
        };
      }

      if (userInfoData['submodel'] == 'sales_user') {
        SalesUser salesUser = SalesUser.fromJson(userInfoData['user']);

        return {
          'user': salesUser,
        };
      }

      if (userInfoData['submodel'] == 'employee_user') {
        EmployeeUser employeeUser = EmployeeUser.fromJson(userInfoData['user']);

        return {
          'user': employeeUser,
        };
      }
    }

    return null;
  }

  Future<StreamInfo> getStreamInfo() async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    final url = await getUrl('/company/stream-info/');
    final token = _prefs.getString('token');
    final res = await _httpClient.get(
        Uri.parse(url),
        headers: getHeaders(token)
    );

    if (res.statusCode == 200) {
      var responseData = json.decode(res.body);

      // create models based on user type
      return StreamInfo.fromJson(responseData);
    }

    throw Exception(res.body);
  }

  Future<String> createStreamPrivateChannel(String toUserId) async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    final url = await getUrl('/company/stream-private-channel-create/');
    final token = _prefs.getString('token');
    final authHeaders = getHeaders(token);
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(authHeaders);
    final res = await _httpClient.post(
        Uri.parse(url),
        body: json.encode(<String, String>{"to_member_user_id": toUserId}),
        headers: allHeaders
    );

    if (res.statusCode == 200) {
      var responseData = json.decode(res.body);
      if (responseData["error"] != null) {
        throw Exception(res.body);
      }

      return responseData["created"];
    }

    return null;
  } //


  Future<bool> getHasBranches() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    final Map<String, String> envVars = Platform.environment;

    if (!_prefs.containsKey('member_has_branches')) {
      if (envVars['TESTING'] != null) {
        _prefs.setBool('member_has_branches', false);
      } else {
        final Member member = await fetchMemberPref();
        _prefs.setBool('member_has_branches', member.hasBranches);
      }
    }

    return _prefs.getBool('member_has_branches');
  }

  Future<int> getEmployeeBranch() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    if (!_prefs.containsKey('employee_branch')) {
      var userData = await utils.getUserInfo();
      var userInfo = userData['user'];
      if (userInfo is EmployeeUser) {
        EmployeeUser employeeUser = userInfo;
        if (employeeUser.employee.branch != null) {
          _prefs.setString('submodel', 'branch_employee_user');
          _prefs.setInt('employee_branch', employeeUser.employee.branch);
        } else {
          _prefs.setString('submodel', 'employee_user');
          _prefs.setInt('employee_branch', 0);
        }
      } else {
        _prefs.setInt('employee_branch', 0);
      }

    }

    return _prefs.getInt('employee_branch');
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

    if (submodel == 'branch_employee_user') {
      return 'orders.list.app_title_employee_user'.tr();
    }

    return null;
  }

  Future<Map<String, dynamic>> openDocument(url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    if (!io.File(file.path).existsSync()) {
      print('file does not EXIST hellup');
      return {
        'result': false,
        'message': 'file does not exist'
      };
    }


    final bool isGranted = await Permission.manageExternalStorage.request().isGranted;
    if (Platform.isIOS || isGranted) {
      final result = await OpenFile.open(file.path);
      print("type=${result.type}  message=${result.message}");
      return {
        'result': result.type == ResultType.done ? true : false,
        'message': result.message
      };
    }

    if (!isGranted) {
      return {
        'result': false,
        'message': 'not granted'
      };
    }

    return {
      'result': false,
      'message': 'unknown error'
    };
  }

  launchURL(String url) async {
    if (url == null || url == '') {
      return;
    }

    Uri _uri = Uri.parse(url);
    if (await canLaunchUrl(_uri)) {
      await launchUrl(_uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  /// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy =  ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  DateTime getMonday() {
    var today = DateTime.now();
    // if it's sunday, use next day as start date
    if (today.weekday == DateTime.sunday) {
      return today.add(Duration(days: 1));
    }

    if (today.weekday == 1) {
      return today;
    }

    return today.subtract(Duration(days: today.weekday - 1));
  }
}

Utils utils = Utils();
