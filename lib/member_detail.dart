import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'login.dart';
import 'utils.dart';
import 'assignedorders_list.dart';


Future<MemberPublic> fetchMember(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int memberPk = prefs.getInt('member_pk');

  var url = await getUrl('/member/detail-public/$memberPk/');
  final response = await client.get(url);

  if (response.statusCode == 200) {
    return MemberPublic.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load member');
}

class MemberPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MemberPageState();
  }
}

class _MemberPageState extends State<MemberPage> {
  MemberPublic member;
  String appBarTitleText = 'Member details';

  Widget _buildLogo(member) => SizedBox(
      width: 100,
      height: 210,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(member.companylogo, cacheWidth: 100),
          ]
      )
  );

  Widget _buildInfoCard(member) => SizedBox(
    height: 210,
    width: 1000,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ListTile(
            title: Text(member.address,
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${member.countryCode}-${member.postal}\n${member.city}'),
            leading: Icon(
              Icons.restaurant_menu,
              color: Colors.blue[500],
            ),
          ),
          Divider(),
          ListTile(
            title: Text(member.tel,
                style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.contact_phone,
              color: Colors.blue[500],
            ),
          ),
        ],
      ),
    ),
  );

  void _setMemberName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final memberName = prefs.getString('member_name');

    setState(() {
      appBarTitleText = memberName;
    });
  }

  @override
  void initState() {
    super.initState();
    _setMemberName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitleText),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: FutureBuilder<MemberPublic>(
          future: fetchMember(http.Client()),
          // ignore: missing_return
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container(
                  child: Center(
                      child: Text("Loading...")
                  )
              );
            } else {
              MemberPublic member = snapshot.data;

              return Center(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(member),
                        Flexible(
                            child: _buildInfoCard(member)
                        ),
                        Column(
                          children: [
                            FutureBuilder<bool>(
                              future: isLoggedInSlidingToken(),
                              builder: (context, snapshot) {
                                bool loggedIn = snapshot.data;
                                print('is logged in: $loggedIn');

                                if (loggedIn == true) {
                                  return RaisedButton(
                                      color: Colors.blue,
                                      textColor: Colors.white,
                                      child: new Text('Go to orders'),
                                      onPressed: () {
                                        Navigator.push(context,
                                            new MaterialPageRoute(
                                                builder: (context) => AssignedOrdersListWidget())
                                        );
                                      }
                                  );
                                } else {
                                  return new Center(
                                      child: new Row(
                                          children: <Widget>[
                                            RaisedButton(
                                              color: Colors.blue,
                                              textColor: Colors.white,
                                              child: new Text('Login'),
                                              onPressed: () {
                                                Navigator.push(context,
                                                  new MaterialPageRoute(
                                                    builder: (context) => LoginPageWidget())
                                                );
                                              }
                                            )
                                          ]
                                      )
                                  );
                                }
                              },
                            )
                          ]
                        )
                      ] // children
                  )
              );
            }
          }
        )
      )
    );
  }
}
