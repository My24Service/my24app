import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  throw Exception('main.error_loading'.tr());
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
  List<MemberPublic> _members = [];
  MemberPublic _member;
  bool _error = false;
  Locale _locale;
  bool _doSkip = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _setBaseUrl();
    await _setLocale();
    await _getLocale();
    await _checkSkipMemberList();
    await _doFetchMembers();
  }

  _checkSkipMemberList() async {
    // check if we should skip the member list
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('skip_member_list')) {
      bool skip = prefs.getBool('skip_member_list');

      if (skip) {
        int memberPk = prefs.getInt('prefered_member_pk');

        if (memberPk != null) {
          await prefs.setInt('member_pk', memberPk);

          MemberPublic member = await fetchMember(http.Client());

          if (member != null) {
            await _storeMemberInfo(member.companycode, member.pk, member.name);
            _member = member;
            _doSkip = true;

            setState(() {});
          }
        }
      }
    }
  }

  _setBaseUrl() async {
    var config = AppConfig();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiBaseUrl', config.apiBaseUrl);
  }

  _setLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('prefered_language_code')) {
      await prefs.setString('prefered_language_code', context.locale.languageCode);
    }
  }

  _getLocale() async {
    String languageCode;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    languageCode = prefs.getString('prefered_language_code');

    setState(() {
      _locale = lang2locale(languageCode);
      context.locale = _locale;
    });
  }

  _doFetchMembers() async {
    if (_doSkip) {
      return;
    }

    Members result;

    try {
      result = await fetchMembers(http.Client());
      setState(() {
        _members = result.results;
      });
    } catch(e) {
      setState(() {
        _error = true;
      });
    }
  }

  _storeMemberInfo(String companycode, int pk, String memberName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // generic prefs
    await prefs.setString('companycode', companycode);
    await prefs.setInt('member_pk', pk);
    await prefs.setString('member_name', memberName);

    // prefered member prefs
    await prefs.setBool('skip_member_list', true);
    await prefs.setInt('prefered_member_pk', pk);
    await prefs.setString('prefered_companycode', companycode);
  }

  Widget _buildList() {
    if (_error) {
      return RefreshIndicator(
        child: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('main.error_loading'.tr())
              ],
            )
        ), onRefresh: () => _doFetchMembers(),
      );
    }

    if (_members.length == 0) {
      return Center(child: CircularProgressIndicator());
    }

    RefreshIndicator list = RefreshIndicator(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: _members.length,
          itemBuilder: (BuildContext context, int index) {
            MemberPublic member = _members[index];

            return ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      member.companylogoUrl),
                ),
                title: Text(member.name),
                subtitle: Text(member.companycode),
                onTap: () async {
                  await _storeMemberInfo(member.companycode, member.pk, member.name);

                  showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('main.alert_title_member_stored'.tr()),
                          content: Text('main.alert_content_member_stored'.tr(
                              namedArgs: {'companyName': member.name})),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(context,
                                    new MaterialPageRoute(builder: (context) => MemberPage())
                                );
                              },
                            ),
                          ],
                        );
                      }
                    );
                } // onTab
            );
          } // itemBuilder
      ),
      onRefresh: () => _doFetchMembers(),
    );

    return Column(
      children: [
        list
      ],
    );
  }

  Widget _buildSkipView(BuildContext context) {
    return Builder(
        builder: (context) => Center(
          child: Column(
              children: [
                CachedNetworkImage(
                  height: 120,
                  width: 100,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  imageUrl: _member.companylogoUrl,
                ),
                Divider(),
                SizedBox(height: 50),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    child: new Text('main.button_continue_to_member'.tr()),
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          new MaterialPageRoute(builder: (context) => MemberPage())
                      );
                    }
                )

              ],
            )
        )
    );
  }

  Widget _showLandingPage(BuildContext context) {
    if(_doSkip) {
      return _buildSkipView(context);
    }

    return _buildList();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: _locale,
      theme: ThemeData(
          primaryColor: Color.fromARGB(255, 255, 153, 51)
      ),
      title: 'main.title'.tr(),
      home: Scaffold(
          appBar: AppBar(
            title: Text('main.app_bar_title'.tr()),
          ),
          body: Container(
              child: Column(
                children: [
                  _showLandingPage(context)
                ],
              )
          )
      ),
    );
  }
}
