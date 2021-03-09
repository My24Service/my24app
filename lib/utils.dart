import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:my24app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';


dynamic getUrl(String path) async {
  final prefs = await SharedPreferences.getInstance();
  String companycode = prefs.getString('companycode');
  String apiBaseUrl = prefs.getString('apiBaseUrl');

  if (companycode == null || companycode == '') {
    companycode = 'demo';
  }

  if (apiBaseUrl == null || apiBaseUrl == '') {
    apiBaseUrl = 'my24service-dev.com';
  }

  return 'https://$companycode.$apiBaseUrl$path';
}

dynamic getBaseUrl() async {
  final prefs = await SharedPreferences.getInstance();
  String companycode = prefs.getString('companycode');
  String apiBaseUrl = prefs.getString('apiBaseUrl');

  if (companycode == null || companycode == '') {
    companycode = 'demo';
  }

  return 'https://$companycode.$apiBaseUrl';
}

dynamic getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('tokenAccess');
}

dynamic getRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('tokenRefresh');
}

dynamic getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Map<String, String> getHeaders(String token) {
  return {'Authorization': 'Bearer $token'};
}

class TokenExpiredException implements Exception {
  String cause;
  TokenExpiredException(this.cause);
}

Future<Token> refreshToken(http.Client client) async {
  final url = await getUrl('/jwt-token/refresh/');
  final refreshToken = await getRefreshToken();
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  print('refreshToken: $refreshToken');
  final res = await client.post(
    url,
    body: json.encode(<String, String>{"refresh": refreshToken}),
    headers: headers,
  );

  if (res.statusCode == 200) {
    Token token = Token.fromJson(json.decode(res.body));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tokenAccess', token.access);
    print('stored new access token: ${token.access}');

    return token;
  }

  return null;
}

Future<SlidingToken> refreshSlidingToken(http.Client client) async {
  final url = await getUrl('/jwt-token/refresh/');
  final token = await getToken();
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final response = await client.post(
    url,
    body: json.encode(<String, String>{"token": token}),
    headers: allHeaders,
  );

  if (response.statusCode == 401) {
    Map<String, dynamic> reponseBody = json.decode(response.body);

    if (reponseBody['code'] == 'token_not_valid') {
      // go to login screen

    }
  }

  if (response.statusCode == 200) {
    SlidingToken token = SlidingToken.fromJson(json.decode(response.body));
    token.checkIsTokenExpired();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token.token);

    return token;
  }

  return null;
}

void displayDialog(context, title, text) => showDialog(
  context: context,
  builder: (context) =>
      AlertDialog(
          title: Text(title),
          content: Text(text)
      ),
);

Future<bool> isLoggedIn() async {
  // get and check token
  String accessToken = await getAccessToken();

  if(accessToken == null) {
    return false;
  }

  // create token object from prefs
  Token token = Token(access: accessToken);

  // check checkIsTokenExpired
  token.checkIsTokenExpired();

  // try to refresh?
  if (token.isExpired) {
    return false;
  }

  return true;
}

Future<bool> isLoggedInSlidingToken() async {
  http.Client client = http.Client();

  // refresh token
  SlidingToken newToken = await refreshSlidingToken(http.Client());

  if(newToken == null) {
    return false;
  }

  // create token object from prefs
  SlidingToken token = SlidingToken(token: newToken.token);

  // check checkIsTokenExpired
  token.checkIsTokenExpired();

  // try to refresh?
  if (token.isExpired) {
    return false;
  }

  // make call to member to check if it's the correct one
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int userId = prefs.getInt('user_id');
  final url = await getUrl('/mobile/assignedorder/list_app/?user_pk=$userId&json');
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  if (response.statusCode == 401 || response.statusCode == 403) {
    return false;
  }

  return true;
}

Future<bool> logout() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('tokenAccess');
  prefs.remove('tokenRefresh');
  prefs.remove('token');

  return true;
}

Future<bool> refreshTokenBackground(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    // do nothing
    return false;
  }

  return true;
}

Future<bool> storeLastPosition(http.Client client) async {
  // get best latest position
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
    return false;
  }

  // store it in the API
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int userId = prefs.getInt('user_id');
  final String token = prefs.getString('token');
  final url = await getUrl('/company/engineer/$userId/store_lon_lat/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'lon': position.longitude,
    'lat': position.latitude,
    'heading': position.heading,
    'speed': position.speed,
  };

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}

Future <List> productTypeAhead(http.Client client, String query) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  final url = await getUrl('/purchase/product/autocomplete/' + '?q=' + query);
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  List result = [];

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var list = parsedJson as List;
    List<PurchaseProduct> results = list.map((i) => PurchaseProduct.fromJson(i)).toList();

    return results;
  }

  return result;
}

Future <List> quotationProductTypeAhead(http.Client client, String query) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  final url = await getUrl('/purchase/product/autocomplete/?q=' + query);
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  List result = [];

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var list = parsedJson as List;
    List<QuotationProduct> results = list.map((i) => QuotationProduct.fromJson(i)).toList();

    return results;
  }

  return result;
}

Widget createTableHeaderCell(String content) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: Text(content, style: TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget createTableColumnCell(String content) {
  return Padding(
    padding: EdgeInsets.all(4.0),
    child: Text(content),
  );
}

Widget createTable(List<TableRow> rows) {
  return Table(
      border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid)),
      children: rows
  );
}

ElevatedButton createBlueElevatedButton(String text, Function callback, { primaryColor=Colors.blue }) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      primary: primaryColor, // background
      onPrimary: Colors.white, // foreground
    ),
    child: new Text(text),
    onPressed: callback,
  );
}

Widget createHeader(String text) {
  return Container(child: Column(
    children: [
      SizedBox(
        height: 10.0,
      ),
      Text(text, style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.grey
      )),
      SizedBox(
        height: 10.0,
      ),
    ],
  ));
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
