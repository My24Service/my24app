import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/company/models/models.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/mobile/pages/assigned_order_list.dart';


class LoginView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    _addListeners();

    return ModalProgressHUD(child: Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          _buildTextFields(),
          Divider(),
          _buildButtons(),
        ],
      ),
    ), inAsyncCall: _saving);
  }

  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _username = "";
  String _password = "";
  bool _saving = false;

  _addListeners() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _username = "";
    } else {
      _username = _emailFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  Widget _buildTextFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new TextField(
              controller: _emailFilter,
              decoration: new InputDecoration(
                  labelText: 'login.username'.tr()
              ),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(
                  labelText: 'login.password'.tr()
              ),
              obscureText: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return new Container(
      child: new Column(
        children: <Widget>[
          createBlueElevatedButton(
              'login.button_login'.tr(), _loginPressed),
          SizedBox(height: 30),
          createBlueElevatedButton(
              'login.button_forgot_password'.tr(), _passwordReset),
        ],
      ),
    );
  }

  _passwordReset () async {
    final url = await utils.getUrl('/company/users/password-reset/#users/reset-password');
    launch(url);
  }

  _navOrderList() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OrderListPage()
        )
    );
  }

  _loginPressed () async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _saving = true;
    });

    var resultToken = await utils.attemptLogIn(_username, _password);

    if (resultToken == null) {
      setState(() {
        _saving = false;
      });

      displayDialog(
          context,
          'login.dialog_error_title',
          'login.dialog_error_content');
      return;
    }

    // fetch user info and determine type
    var user = await utils.getUserInfo(resultToken.getUserPk());

    setState(() {
      _saving = false;
    });

    // engineer?
    if (user is EngineerUser) {
      EngineerUser engineerUser = user;
      prefs.setInt('user_id', engineerUser.id);
      prefs.setString('first_name', engineerUser.firstName);
      prefs.setString('submodel', 'engineer');

      // request permissions
      await utils.requestFCMPermissions();

      // navigate to assignedorders
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AssignedOrderListPage()
          )
      );
    }

    // customer?
    if (user is CustomerUser) {
      CustomerUser customerUser = user;
      prefs.setInt('user_id', customerUser.id);
      prefs.setInt('customer_pk', customerUser.customerDetails.id);
      prefs.setString('first_name', customerUser.firstName);
      prefs.setString('submodel', 'customer_user');

      // navigate to orders
      _navOrderList();
    }

    // planning?
    if (user is PlanningUser) {
      PlanningUser plannnigUser = user;
      prefs.setInt('user_id', plannnigUser.id);
      prefs.setString('first_name', plannnigUser.firstName);
      prefs.setString('submodel', 'planning_user');

      // navigate to orders
      _navOrderList();
    }

    // planning?
    if (user is SalesUser) {
      SalesUser salesUser = user;
      prefs.setInt('user_id', salesUser.id);
      prefs.setString('first_name', salesUser.firstName);
      prefs.setString('submodel', 'sales_user');

      // navigate to orders
      _navOrderList();
    }
  }
}