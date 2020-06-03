import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';


class InValidTokenException implements Exception {
  String term;

  String errMsg() => 'Invalid token';

  InValidTokenException({this.term});
}

Future<Token> attemptLogIn(http.Client client, String username, String password) async {
  final prefs = await SharedPreferences.getInstance();
  final companycode = prefs.getString('companycode') ?? 'demo';
  final apiBaseUrl = prefs.getString('apiBaseUrl');
  final url = 'https://$companycode.$apiBaseUrl';

  var res = await client.post(
      '$url/api/token/',
      body: {
        "username": username,
        "password": password
      }
  );

  if (res.statusCode == 200) {
    Token token = Token.fromJson(json.decode(res.body));

    // sanity checks
    token.checkIsTokenValid();
    token.checkIsTokenExpired();

    return token;
  }

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

  void displayDialog(context, title, text) => showDialog(
    context: context,
    builder: (context) =>
        AlertDialog(
            title: Text(title),
            content: Text(text)
        ),
  );

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
    print('The user wants to login with $_username and $_password');
    var resultToken = await attemptLogIn(http.Client(), _username, _password);
    if(resultToken != null) {
      var expires = resultToken.getExpAccesss();
      print('Logged in! Expires: $expires');
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', resultToken.access);
//      Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) => HomePage.fromBase64(jwt)
//          )
//      );
    } else {
      print('error logging in');
//      displayDialog(context, "An Error Occurred", "No account was found matching that username and password");
    }
  }

  void _passwordReset () {
    print("The user wants a password reset request sent to $_username");
  }
}
