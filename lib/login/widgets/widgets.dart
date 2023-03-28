import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/company/models/models.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/mobile/pages/assigned.dart';

import '../../core/models/models.dart';
import '../../company/pages/workhours_list.dart';

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
          createDefaultElevatedButton(
              'login.button_login'.tr(),
              _loginPressed
          ),
          SizedBox(height: 30),
          createElevatedButtonColored(
              'login.button_forgot_password'.tr(),
              _passwordReset
          ),
        ],
      ),
    );
  }

  _passwordReset () async {
    final url = await utils.getUrl('/frontend/#/reset-password');
    launch(url.replaceAll('/api', ''));
  }

  _navOrderList() {
    final page = OrderListPage();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _navWorkhours() {
    final page = UserWorkHoursListPage();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _loginPressed () async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _saving = true;
    });

    SlidingToken resultToken = await utils.attemptLogIn(_username, _password);

    if (resultToken == null) {
      setState(() {
        _saving = false;
      });

      displayDialog(
          context,
          'login.dialog_error_title'.tr(),
          'login.dialog_error_content'.tr()
      );
      return;
    }

    // fetch user info and determine type
    var userData = await utils.getUserInfo();
    var userInfo = userData['user'];

    setState(() {
      _saving = false;
    });

    // engineer?
    if (userInfo is EngineerUser) {
      EngineerUser engineerUser = userInfo;
      prefs.setInt('user_id', engineerUser.id);
      prefs.setString('first_name', engineerUser.firstName);
      prefs.setString('email', engineerUser.email);
      prefs.setString('submodel', 'engineer');

      // request permissions
      await utils.requestFCMPermissions();

      // navigate to assignedorders
      final page = AssignedOrdersPage();

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => page
          )
      );
    }

    // customer?
    if (userInfo is CustomerUser) {
      CustomerUser customerUser = userInfo;
      prefs.setInt('user_id', customerUser.id);
      prefs.setString('email', customerUser.email);
      prefs.setInt('customer_pk', customerUser.customerDetails.id);
      prefs.setString('first_name', customerUser.firstName);
      prefs.setString('submodel', 'customer_user');

      // navigate to orders
      _navOrderList();
    }

    // planning?
    if (userInfo is PlanningUser) {
      PlanningUser planningUser = userInfo;
      prefs.setInt('user_id', planningUser.id);
      prefs.setString('email', planningUser.email);
      prefs.setString('first_name', planningUser.firstName);
      prefs.setString('submodel', 'planning_user');

      // navigate to orders
      _navOrderList();
    }

    // sales?
    if (userInfo is SalesUser) {
      SalesUser salesUser = userInfo;
      prefs.setInt('user_id', salesUser.id);
      prefs.setString('email', salesUser.email);
      prefs.setString('first_name', salesUser.firstName);
      prefs.setString('submodel', 'sales_user');

      // navigate to orders
      _navOrderList();
    }

    // employee?
    if (userInfo is EmployeeUser) {
      EmployeeUser employeeUser = userInfo;
      prefs.setInt('user_id', employeeUser.id);
      prefs.setString('email', employeeUser.email);
      prefs.setString('first_name', employeeUser.firstName);

      if (employeeUser.employee.branch != null) {
        prefs.setString('submodel', 'branch_employee_user');
        prefs.setInt('employee_branch', employeeUser.employee.branch);
        _navOrderList();
      } else {
        prefs.setString('submodel', 'employee_user');
        prefs.setInt('employee_branch', 0);
        _navWorkhours();
      }
    }
  }
}
