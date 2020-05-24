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
  final String companylogo;
  final String name;
  final String address;
  final String postal;
  final String city;
  final String countryCode;
  final String tel;
  final String email;

  MemberPublic({
    this.companycode,
    this.companylogo,
    this.name,
    this.address,
    this.postal,
    this.city,
    this.countryCode,
    this.tel,
    this.email,
  });

  factory MemberPublic.fromJson(Map<String, dynamic> parsedJson) {
    return MemberPublic(
      companycode: parsedJson['companycode'],
      companylogo: parsedJson['companylogo'],
      name: parsedJson['name'],
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      tel: parsedJson['tel'],
      email: parsedJson['email'],
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
        title: Text(member.name),
      ),
      body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
//          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(member),
            Flexible(
              child: _buildInfoCard(member)
            ),
          ]
        ),
    );
  }
}
