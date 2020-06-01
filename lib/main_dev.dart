import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'member_list.dart';
import 'app_config_dev.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(My24App());

class My24App extends StatefulWidget {
  My24App({Key key}) : super(key: key);

  @override
  _My24AppState createState() => _My24AppState();
}

class _My24AppState extends State<My24App> with MembersListMixin {
  @override
  void initState() {
    super.initState();
    setBaseUrl();
    members = fetchMembers(http.Client());
  }

  void setBaseUrl() async {
    var config = AppConfig();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiBaseUrl', config.apiBaseUrl);
  }
}
