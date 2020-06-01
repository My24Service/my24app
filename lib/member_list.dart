import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'member_detail.dart';


Future<Members> fetchMembers(http.Client client) async {
  final prefs = await SharedPreferences.getInstance();
  final companycode = prefs.getString('companycode') ?? 'demo';
  final apiBaseUrl = prefs.getString('apiBaseUrl');
  var url = 'https://$companycode.$apiBaseUrl/member/list-public/';

  final response = await client.get(url);

  if (response.statusCode == 200) {
    return Members.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load members');
}

class MembersListMixin extends Object {
  Future<Members> members;

  _setCompanycode(String companycode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('storing $companycode');
    await prefs.setString('companycode', companycode);
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
        body: Center(
          child: FutureBuilder<Members>(
              future: members,
              builder: (context, snapshot) {
                print(snapshot.data);
                if (snapshot.data == null) {
                  return Container(
                      child: Center(
                          child: Text("Loading...")
                      )
                  );
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.results.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  snapshot.data.results[index].companylogo
                              ),
                            ),
                            title: Text(snapshot.data.results[index].name),
                            subtitle: Text(snapshot.data.results[index].companycode),
                            onTap: () {
                              _setCompanycode(snapshot.data.results[index].companycode);
                              Navigator.push(context,
                                  new MaterialPageRoute(builder: (context) =>
                                      MemberPage(snapshot.data.results[index]))
                              );
                            } // onTab
                        );
                      } // itemBuilder
                  );
                } // else
              } // builder
          ),
        ),
      ),
    );
  }
}
