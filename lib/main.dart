import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

import 'utils.dart';
import 'models.dart';
import 'member_detail.dart';

import 'app_config.dart';


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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: [
          Locale('en', 'US'),
          Locale('nl', 'NL'),
          // Locale('de', 'DE'),
        ],
        path: 'resources/langs',
        fallbackLocale: Locale('en', 'US'),
        child: My24App()
    ),
  );

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
  }

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _setBaseUrl();
    await _doFetchMembers();
  }

  _setBaseUrl() async {
    var config = AppConfig();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiBaseUrl', config.apiBaseUrl);
  }

  _doFetchMembers() async {
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

  Widget _buildList() {
    if (error) {
      return Center(
          child: Column(
            children: [
              SizedBox(height: 30),
              Text('main.error_loading')
            ],
          )
      );
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
                onTap: () async {
                  await _storeMemberInfo(
                      members[index].companycode,
                      members[index].pk,
                      members[index].name);

                  Navigator.push(context,
                      new MaterialPageRoute(builder: (context) => MemberPage())
                  );
                } // onTab
            );
          } // itemBuilder
      ),
      onRefresh: () => _doFetchMembers(),
    )
        : Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
          primaryColor: Color.fromARGB(255, 255, 153, 51)
      ),
      title: 'members.title'.tr(),
      home: Scaffold(
          appBar: AppBar(
            title: Text('main.title'.tr()),
          ),
          body: Container(
              child: _buildList()
          )
      ),
    );
  }
}
