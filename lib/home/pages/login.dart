import 'package:flutter/material.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/member/widgets/detail.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: utils.getMemberName(),
        builder: (ctx, snapshot) {
          return Scaffold(
              appBar: AppBar(
                title: Text(snapshot.data != null ? snapshot.data : ''),
              ),
              body: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: ShowMainView()
              )
          );
        }
    );
  }
}
