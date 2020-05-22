import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


Future<Members> fetchMembers() async {
  final response = await http.get('https://demo.my24service-dev.com/member/list-public/');

  if (response.statusCode == 200) {
    return Members.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load members');
}

class Members {
  final int count;
  final String next;
  final String previous;
  final List<MemberPublic> results;

  Members({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Members.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<MemberPublic> results = list.map((i) => MemberPublic.fromJson(i)).toList();

    return Members(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results
    );
  }
}

class MemberPublic {
  final String companycode;
  final String name;
  final String companylogo;

  MemberPublic({
    this.companycode,
    this.name,
    this.companylogo
  });

  factory MemberPublic.fromJson(Map<String, dynamic> parsedJson) {
    return MemberPublic(
      companycode: parsedJson['companycode'],
      name: parsedJson['name'],
      companylogo: parsedJson['companylogo'],
    );
  }
}

void main() => runApp(My24App());

class My24App extends StatefulWidget {
  My24App({Key key}) : super(key: key);

  @override
  _My24AppState createState() => _My24AppState();
}

class _My24AppState extends State<My24App> {
  Future<Members> members;

  @override
  void initState() {
    super.initState();
    members = fetchMembers();
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

class MemberPage extends StatelessWidget {

  final MemberPublic member;

  MemberPage(this.member);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(member.name),
        )
    );
  }
}
