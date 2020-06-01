import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<String> attemptLogIn(String username, String password) async {
  final prefs = await SharedPreferences.getInstance();
  final companycode = prefs.getString('companycode') ?? 'demo';
  final apiBaseUrl = prefs.getString('apiBaseUrl');
  var url = 'https://$companycode.$apiBaseUrl';

  var res = await http.post(
      "$url/api-token-auth/",
      body: {
        "username": username,
        "password": password
      }
  );
  if(res.statusCode == 200) return res.body;
  return null;
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Simple Login Demo',
      theme: new ThemeData(
          primarySwatch: Colors.blue
      ),
      home: new LoginPageWidget(),
    );
  }
}

class LoginPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

// Used for controlling whether the user is loggin or creating an account
enum FormType {
  login,
  register
}

class _LoginPageState extends State<LoginPageWidget> {

  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _username = "";
  String _password = "";
  FormType _form = FormType.login; // our default setting is to login, and we should switch to creating an account when the user chooses to

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

  // Swap in between our two forms, registering and logging in
  void _formChange () async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildBar(context),
      body: new Container(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            _buildTextFields(),
            _buildButtons(),
          ],
        ),
      ),
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
    if (_form == FormType.login) {
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
    } else {
      return new Container(
        child: new Column(
          children: <Widget>[
            new RaisedButton(
              child: new Text('Create an Account'),
              onPressed: _createAccountPressed,
            ),
            new FlatButton(
              child: new Text('Have an account? Click here to login.'),
              onPressed: _formChange,
            )
          ],
        ),
      );
    }
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password

  void _loginPressed () async {
    var result = await attemptLogIn(_username, _password);
    if(result != null) {
      print('login result: $result');
      var token = Token.fromJson(json.decode(result));
      print('login result: ${token.token}');
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token.token);
//      Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) => HomePage.fromBase64(jwt)
//          )
//      );
    } else {
      print('error logging in: $result');
//      displayDialog(context, "An Error Occurred", "No account was found matching that username and password");
    }
    print('The user wants to login with $_username and $_password');
  }

  void _createAccountPressed () {
    print('The user wants to create an accoutn with $_username and $_password');
  }

  void _passwordReset () {
    print("The user wants a password reset request sent to $_username");
  }
}
