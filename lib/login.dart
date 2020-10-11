import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'assignedorders_list.dart';
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
  }

  return null;
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
          new RaisedButton(
            child: new Text('Login'),
            onPressed: _loginPressed,
          ),
          new FlatButton(
            child: new Text('Forgot Password?'),
            onPressed: _passwordReset,
          )
        ],
      ),
    );
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password

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

      // navigate to assignedorders
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AssignedOrdersListWidget()
          )
      );
    }

    // customer?
    if (user is CustomerUser) {
      print('customer!');
      final prefs = await SharedPreferences.getInstance();

      CustomerUser customerUser = user;
      prefs.setInt('user_id', customerUser.id);
      prefs.setString('first_name', customerUser.firstName);

      // navigate to orders
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AssignedOrdersListWidget()
          )
      );
    }
  }

  void _passwordReset () {
  }
}
