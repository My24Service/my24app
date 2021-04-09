import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/member/models/models.dart';

// ignore: must_be_immutable
class showMainView extends StatelessWidget {
  final bool doSkip;

  showMainView({
    Key key,
    @required this.doSkip,
  }) : super(key: key);


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

  Widget _showMainView(MemberPublic _member) {
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
    // TODO: implement build
    throw UnimplementedError();
  }

}
