import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'login.dart';
import 'utils.dart';
import 'assignedorders_list.dart';
import 'order_list.dart';


Future<MemberPublic> fetchMember(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int memberPk = prefs.getInt('member_pk');

  var url = await getUrl('/member/detail-public/$memberPk/');
  final response = await client.get(url);

  if (response.statusCode == 200) {
    return MemberPublic.fromJson(json.decode(response.body));
  }

  throw Exception('member_detail.exception_fetch'.tr());
}

class MemberPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MemberPageState();
  }
}

class _MemberPageState extends State<MemberPage> {
  MemberPublic member;
  String appBarTitleText = 'member_detail.app_bar_title'.tr();

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _setMemberName();
  }

  Widget _buildLogo(member) => SizedBox(
      width: 100,
      height: 210,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(member.companylogoUrl,
                cacheWidth: 100),
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
            title: Text('${member.address}',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
                '${member.countryCode}-${member.postal}\n${member.city}'),
            leading: Icon(
              Icons.restaurant_menu,
              color: Colors.blue[500],
            ),
          ),
          Divider(),
          ListTile(
            title: Text('${member.tel}',
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

  void _navAssignedOrders() {
    Navigator.push(context, new MaterialPageRoute(
          builder: (context) => AssignedOrdersListPage())
    );
  }

  void _navOrders() {
    Navigator.push(context, new MaterialPageRoute(
        builder: (context) => OrderListPage())
    );
  }

  Future<Widget> _createGoToOrdersButton() async {
    // fetch user info and determine type
    final String submodel = await getUserSubmodel();

    if (submodel == 'engineer') {
      return createBlueElevatedButton(
        'member_detail.button_go_to_orders'.tr(), _navAssignedOrders);
    }

    return createBlueElevatedButton(
      'member_detail.button_go_to_orders'.tr(), _navOrders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$appBarTitleText'),
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
                      child: Text('generic.loading'.tr())
                  )
              );
            } else {
              MemberPublic member = snapshot.data;

              return Center(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(member),
                        Flexible(
                            child: _buildInfoCard(member)
                        )
                      ]
                    ),
                    FutureBuilder<bool>(
                      future: isLoggedInSlidingToken(),
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Container(
                            child: Center(
                              child: Text('generic.loading'.tr())
                            )
                          );
                        } else {
                          bool loggedIn = snapshot.data;
                          if (loggedIn == true) {
                            return FutureBuilder<Widget>(
                              future: _createGoToOrdersButton(),
                              builder: (context, snapshot) {
                                if (snapshot.data == null) {
                                  return Container(
                                    child: Center(
                                      child: Text('generic.loading'.tr())
                                    )
                                  );
                                } else {
                                  return snapshot.data;
                                }
                              }
                            );
                          } else {
                            return new Container(
                              child: Center(child: RaisedButton(
                                color: Colors.blue,
                                textColor: Colors.white,
                                child: new Text('member_detail.button_login'.tr()),
                                onPressed: () {
                                  Navigator.push(context,
                                    new MaterialPageRoute(builder: (context) => LoginPageWidget())
                                  );
                                }
                              )
                            ));
                          }
                        }
                      },
                    )
                  ]
                )
              );
            }
          }
        )
      )
    );
  }
}
