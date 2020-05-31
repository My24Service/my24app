import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'member_list.dart';


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
    members = fetchMembers(http.Client());
  }
}
