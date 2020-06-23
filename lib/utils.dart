import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:my24app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';


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

dynamic getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('tokenAccess');
}

dynamic getRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('tokenRefresh');
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

Future<bool> logout() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('tokenAccess');
  prefs.remove('tokenRefresh');

  return true;
}
