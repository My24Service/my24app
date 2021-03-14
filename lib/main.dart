import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'utils.dart';
import 'models.dart';
import 'member_detail.dart';

import 'app_config_dev.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

Future<Members> fetchMembers(http.Client client) async {
  var url = await getUrl('/member/list-public/');
  final response = await client.get(url);

  if (response.statusCode == 200) {
    return Members.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load members');
}

void main() {
  runApp(My24App());
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

class My24App extends StatefulWidget {
  My24App({Key key}) : super(key: key);

  @override
  _My24AppState createState() => _My24AppState();
}

class _My24AppState extends State<My24App>  {
  List<MemberPublic> members = [];
  bool error = false;

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
  }

  void _doFetch() async {
    Members result;

    try {
      result = await fetchMembers(http.Client());
      setState(() {
        members = result.results;
      });
    } catch(e) {
      setState(() {
        error = true;
      });
    }
  }

  Future<void> _getData() async {
    setState(() {
      _doFetch();
    });
  }

  Widget _buildList() {
    if (error) {
      return Text('Error loading members');
    }

    return members.length != 0
        ? RefreshIndicator(
      child: ListView.builder(
          itemCount: members.length,
          itemBuilder: (BuildContext context, int index) {
            MemberPublic member = members[index];

            return ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      members[index].companylogoUrl),
                  // backgroundImage: NetworkImage(
                  //     members[index].companylogo
                  // ),
                ),
                title: Text(members[index].name),
                subtitle: Text(members[index].companycode),
                onTap: () {
                  print(members[index]);
                  _storeMemberInfo(
                      members[index].companycode,
                      members[index].pk, members[index].name);
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
      theme: ThemeData(
          primaryColor: Color.fromARGB(255, 255, 153, 51)
      ),
      title: 'Members',
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
