import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/login/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text('login.app_bar_title'.tr()),
        centerTitle: true,
      ),
      body: LoginView(),
    );
  }
}
