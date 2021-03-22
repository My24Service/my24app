import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'assignedorders_list.dart';
import 'order_list.dart';
import 'models.dart';
import 'utils.dart';


Future<SlidingToken> attemptLogIn(http.Client client, String username, String password) async {
  final url = await getUrl('/jwt-token/');
  final res = await client.post(
      url,
      body: {
        "username": username,
        "password": password
      }
  );

  if (res.statusCode == 200) {
    SlidingToken token = SlidingToken.fromJson(json.decode(res.body));
    token.checkIsTokenExpired();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token.token);

    return token;
  }

  return null;
}

Future<dynamic> getUserInfo(http.Client client, int pk) async {
  final url = await getUrl('/company/user-info/$pk/');
  final token = await getToken();
  final res = await client.get(
      url,
      headers: getHeaders(token)
  );

  if (res.statusCode == 200) {
    var userData = json.decode(res.body);

    // create models based on user type
    if (userData['submodel'] == 'engineer') {
      EngineerUser engineer = EngineerUser.fromJson(userData['user']);

      return engineer;
    }

    if (userData['submodel'] == 'customer_user') {
      CustomerUser customerUser = CustomerUser.fromJson(userData['user']);

      return customerUser;
    }

    if (userData['submodel'] == 'planning_user') {
      PlanningUser planningUser = PlanningUser.fromJson(userData['user']);

      return planningUser;
    }

    if (userData['submodel'] == 'sales_user') {
      SalesUser salesUser = SalesUser.fromJson(userData['user']);

      return salesUser;
    }
}
  return null;
}

Future<void> requestFCMPermissions() async {
  // request permissions
  final prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('fcm_allowed')) {
    bool isAllowed = false;

    if (Platform.isAndroid) {
      isAllowed = true;
    } else {
      await Firebase.initializeApp();
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        sound: true,
        announcement: false,
        badge: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      // are we allowed?
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        isAllowed = true;
      }
    }

    prefs.setBool('fcm_allowed', isAllowed);

    if (isAllowed) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      });
    }
  }
}


class LoginPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPageWidget> {
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _username = "";
  String _password = "";
  bool _saving = false;

  _LoginPageState() {
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildBar(context),
      body: ModalProgressHUD(child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildTextFields(),
            Divider(),
            _buildButtons(),
          ],
        ),
      ), inAsyncCall: _saving),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text('Login'),
      centerTitle: true,
    );
  }

  Widget _buildTextFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new TextField(
              controller: _emailFilter,
              decoration: new InputDecoration(
                  labelText: 'Username'
              ),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(
                  labelText: 'Password'
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
          createBlueElevatedButton('Login', _loginPressed),
          createBlueElevatedButton('Forgot Password?', _passwordReset),
        ],
      ),
    );
  }

  void _passwordReset () async {
    final url = await getUrl('/company/users/password-reset/#users/reset-password');
    launch(url);
  }

  void _loginPressed () async {
    setState(() {
      _saving = true;
    });

    var resultToken = await attemptLogIn(http.Client(), _username, _password);

    if (resultToken == null) {
      setState(() {
        _saving = false;
      });

      displayDialog(context, "An Error Occurred",
          "No account was found matching that username and password");
      return;
    }

    // fetch user info and determine type
    var user = await getUserInfo(http.Client(), resultToken.getUserPk());

    setState(() {
      _saving = false;
    });

    // engineer?
    if (user is EngineerUser) {
      final prefs = await SharedPreferences.getInstance();

      EngineerUser engineerUser = user;
      prefs.setInt('user_id', engineerUser.id);
      prefs.setString('first_name', engineerUser.firstName);
      prefs.setString('submodel', 'engineer');

      // request permissions
      await requestFCMPermissions();

      // navigate to assignedorders
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AssignedOrdersListPage()
          )
      );
    }

    // customer?
    if (user is CustomerUser) {
      final prefs = await SharedPreferences.getInstance();

      CustomerUser customerUser = user;
      prefs.setInt('user_id', customerUser.id);
      prefs.setInt('customer_pk', customerUser.customerDetails.id);
      prefs.setString('first_name', customerUser.firstName);
      prefs.setString('submodel', 'customer_user');

      // navigate to orders
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderListPage()
          )
      );
    }

    // planning?
    if (user is PlanningUser) {
      final prefs = await SharedPreferences.getInstance();

      PlanningUser plannnigUser = user;
      prefs.setInt('user_id', plannnigUser.id);
      prefs.setString('first_name', plannnigUser.firstName);
      prefs.setString('submodel', 'planning_user');

      // navigate to orders
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderListPage()
          )
      );
    }

    // planning?
    if (user is SalesUser) {
      final prefs = await SharedPreferences.getInstance();

      SalesUser salesUser = user;
      prefs.setInt('user_id', salesUser.id);
      prefs.setString('first_name', salesUser.firstName);
      prefs.setString('submodel', 'planning_user');

      // navigate to orders
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderListPage()
          )
      );
    }
  }
}
