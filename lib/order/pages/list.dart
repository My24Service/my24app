import 'package:flutter/material.dart';

class OrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        // title: new Text('Login'),
        centerTitle: true,
      ),
      // body: LoginView(),
    );
  }
}
