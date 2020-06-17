import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'login.dart';
import 'utils.dart';


Future<MemberPublic> fetchMember(http.Client client, memberPk) async {
  var url = await getUrl('/member/detail-public/$memberPk/');
  final response = await client.get(url);

  if (response.statusCode == 200) {
    return MemberPublic.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load members');
}

class MemberPage extends StatelessWidget {
  final MemberPublic member;

  MemberPage({Key key, @required this.member}) : super(key: key);

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
        mainAxisSize: MainAxisSize.min,
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
          ListTile(
            title: Text(member.email),
            leading: Icon(
              Icons.contact_mail,
              color: Colors.blue[500],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.member.name),
      ),
      body: Center(
        child: FutureBuilder<MemberPublic>(
          future: fetchMember(http.Client(), this.member.pk),
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
//                mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogo(member),
                        Flexible(
                            child: _buildInfoCard(member)
                        ),
                        Center(
                          child:
                          new RaisedButton(
                              child: new Text('Login'),
                              onPressed: () {
                                Navigator.push(context,
                                    new MaterialPageRoute(
                                        builder: (context) => LoginPageWidget())
                                );
                              }
                          ),
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
