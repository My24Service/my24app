import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'utils.dart';
import 'models.dart';
import 'member_detail.dart';

import 'app_config_dev.dart';

const refreshTokenBackgroundKey = "refreshTokenBackground";
// const storeLastPositionKey = "storeLastPosition";

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    if (task == refreshTokenBackgroundKey) {
      print("Native called background task: $refreshTokenBackgroundKey");
      Future<bool> result = refreshTokenBackground(http.Client());
      return Future.value(result);
    }

    // if (task == storeLastPositionKey) {
    //   print("Native called background task: $storeLastPositionKey");
    //   Future<bool> result = storeLastPosition(http.Client());
    //   return Future.value(result);
    // }

    return null;
  });
}

Future<Members> fetchMembers(http.Client client) async {
  var url = await getUrl('/member/list-public/');
  final response = await client.get(url);

  if (response.statusCode == 200) {
    return Members.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load members');
}

void main() => runApp(My24App());

class My24App extends StatefulWidget {
  My24App({Key key}) : super(key: key);

  @override
  _My24AppState createState() => _My24AppState();
}

class _My24AppState extends State<My24App>  {
  List<MemberPublic> members = [];

  void _initWorkManager() {
    print('Init workmanager');
    Workmanager.initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );

    print('Register tasks');
    Workmanager.registerPeriodicTask(
      "1", // unique name
      refreshTokenBackgroundKey,
      initialDelay: Duration(seconds: 10),
    );

    // Workmanager.registerPeriodicTask(
    //   "2", // unique name
    //   storeLastPositionKey,
    //   initialDelay: Duration(seconds: 10),
    // );
  }

  _storeMemberInfo(String companycode, int pk, String memberName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('companycode', companycode);
    await prefs.setInt('member_pk', pk);
    await prefs.setString('member_name', memberName);
    print('stored companycode: $companycode with member_pk=$pk, name=$memberName');
  }

  void _setBaseUrl() async {
    var config = AppConfig();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiBaseUrl', config.apiBaseUrl);
  }

  @override
  void initState() {
    super.initState();
    _setBaseUrl();
    _getData();
    _doFetch();
    _initWorkManager();
  }

  void _doFetch() async {
    Members result;

    result = await fetchMembers(http.Client());

    setState(() {
      members = result.results;
    });
  }

  Future<void> _getData() async {
    setState(() {
      _doFetch();
    });
  }

  Widget _buildList() {
    return members.length != 0
        ? RefreshIndicator(
      child: ListView.builder(
          itemCount: members.length,
          itemBuilder: (BuildContext context, int index) {
            MemberPublic member = members[index];

            return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      members[index].companylogo
                  ),
                ),
                title: Text(members[index].name),
                subtitle: Text(members[index].companycode),
                onTap: () {
                  print(members[index]);
                  _storeMemberInfo(members[index].companycode, members[index].pk, members[index].name);
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (context) => MemberPage())
                  );
                } // onTab
            );
          } // itemBuilder
      ),
      onRefresh: _getData,
    )
        : Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Members',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text('Choose member'),
          ),
          body: Container(
              child: _buildList()
          )
      ),
    );
  }
}
