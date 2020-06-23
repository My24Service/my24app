import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my24app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'assignedorders_list.dart';
import 'utils.dart';


Future<Token> attemptLogIn(http.Client client, String username, String password) async {
  final url = await getUrl('/jwt-token/');
  final res = await client.post(
      url,
      body: {
        "username": username,
        "password": password
      }
  );

  if (res.statusCode == 200) {
    Token token = Token.fromJson(json.decode(res.body));

    // sanity checks
    token.checkIsTokenValid();
//    token.checkIsTokenExpired();

    return token;
  }

  return null;
}

Future<dynamic> getUserInfo(http.Client client, int pk) async {
  final url = await getUrl('/company/user-info/$pk/');
  final token = await getAccessToken();
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
    var resultToken = await attemptLogIn(http.Client(), _username, _password);

    if (resultToken == null) {
      displayDialog(context, "An Error Occurred",
          "No account was found matching that username and password");
      return;
    }

    // we're good, store tokens
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tokenAccess', resultToken.access);
    prefs.setString('tokenRefresh', resultToken.refresh);

    // fetch user info and determine type
    var user = await getUserInfo(http.Client(), resultToken.getUserPk());

    if (user is EngineerUser) {
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
  }

  void _passwordReset () {
//    print("The user wants a password reset request sent to $_username");
  }
}
