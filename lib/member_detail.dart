import 'package:flutter/material.dart';

import 'models.dart';
import 'login.dart';


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
            Center(
              child:
                new RaisedButton(
                  child: new Text('Login'),
                  onPressed: () {
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (context) => LoginPageWidget())
                    );
                  }
                ),
            )
          ]
      ),
    );
  }
}
