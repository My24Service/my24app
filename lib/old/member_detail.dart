import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'login.dart';
import 'utils.dart';
import 'assignedorders_list.dart';
import 'order_list.dart';
import 'main.dart';


class MemberPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MemberPageState();
  }
}

class _MemberPageState extends State<MemberPage> {
  MemberPublic _member;
  String _appBarTitleText = 'member_detail.app_bar_title'.tr();
  ElevatedButton _goToOrdersButton;
  bool _loggedIn = false;
  bool _inAsyncCall = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    setState(() {
      _inAsyncCall = true;
    });

    await _doFetchMember();
    await _checkIsLoggedIn();
    await _setMemberName();
    await _setGoToOrdersButton();

    setState(() {
      _inAsyncCall = false;
    });
  }

  _checkIsLoggedIn() async {
    _loggedIn = await isLoggedInSlidingToken();
  }

  _setGoToOrdersButton() async {
    // fetch user info and determine type
    final String submodel = await getUserSubmodel();

    if (submodel == 'engineer') {
      _goToOrdersButton = createBlueElevatedButton(
          'member_detail.button_go_to_orders'.tr(), _navAssignedOrders);
    } else {
      _goToOrdersButton = createBlueElevatedButton(
          'member_detail.button_go_to_orders'.tr(), _navOrders);
    }
  }

  _setMemberName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final memberName = prefs.getString('member_name');
    _appBarTitleText = memberName;
  }

  _doFetchMember() async {
    try {
      _member = await fetchMember(http.Client());
    } catch(e) {
      setState(() {
        _error = true;
      });
    }
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

  Widget _buildLogo() => SizedBox(
      width: 100,
      height: 210,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_member != null)
              Image.network(_member.companylogoUrl,
                  cacheWidth: 100),
          ]
      )
  );

  Widget _getButton() {
    if (_member == null && _inAsyncCall) {
      return Center(child: CircularProgressIndicator());
    }

    if (_loggedIn == true) {
      return _goToOrdersButton;
    }

    if (!_loggedIn && !_inAsyncCall) {
      return Container(
          child: Center(child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // background
                onPrimary: Colors.white, // foreground
              ),
              child: new Text('member_detail.button_login'.tr()),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(
                        builder: (context) => LoginPageWidget())
                );
              }
          ))
      );
    }
  }

  Widget _showMainView() {
    if (_error) {
      return RefreshIndicator(
        child: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('member_detail.exception_fetch'.tr())
              ],
            )
        ), onRefresh: () => _doFetchMember(),
      );
    }

    if (_member == null && _inAsyncCall) {
      return Center(child: CircularProgressIndicator());
    }

    return Center(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                Flexible(
                  child: buildMemberInfoCard(_member)
                )
              ]
            ),
            _getButton(),
            Spacer(),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // background
                  onPrimary: Colors.white, // foreground
                ),
                child: new Text('member_detail.button_member_list'.tr()),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();

                  prefs.remove('skip_member_list');
                  prefs.remove('prefered_member_pk');
                  prefs.remove('prefered_companycode');

                  Navigator.pushReplacement(context,
                      new MaterialPageRoute(builder: (context) => My24App())
                  );
                }
            )
          ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$_appBarTitleText'),
        ),
        body: Padding(
            padding: EdgeInsets.all(15.0),
            child: _showMainView()
        )
    );
  }
}
