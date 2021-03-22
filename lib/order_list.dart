import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'utils.dart';
import 'order_detail.dart';


Future<Orders> fetchOrders(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // make call
  final String token = newToken.token;
  final url = await getUrl('/order/order/?orders=&page=1');
  final response = await client.get(
    url,
    headers: getHeaders(token)
  );

  if (response.statusCode == 401) {
    Map<String, dynamic> reponseBody = json.decode(response.body);

    if (reponseBody['code'] == 'token_not_valid') {
      throw TokenExpiredException('token expired');
    }
  }

  if (response.statusCode == 200) {
    refreshTokenBackground(client);
    Orders results = Orders.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('Failed to load orders: ${response.statusCode}, ${response.body}');
}

class OrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderState();
  }
}

class _OrderState extends State<OrderListPage> {
  List<Order> _orders = [];
  bool _fetchDone = false;
  Widget _drawer;
  String _title;

  _storeOrderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_pk', pk);
  }

  _doFetchOrders() async {
    Orders result = await fetchOrders(http.Client());

    setState(() {
      _fetchDone = true;
      _orders = result.results;
    });
  }

  void _getDrawerForUser() async {
    Widget drawer = await getDrawerForUser(context);

    setState(() {
      _drawer = drawer;
    });
  }

  void _getTitle() async {
    String title = await getOrderListTitleForUser();

    setState(() {
      _title = title;
    });
  }

  Widget _buildList() {
    if (_orders.length == 0 && _fetchDone) {
      return RefreshIndicator(
        child: Center(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Text('No orders.')
                      ],
                    )
                )
              ]
          )
        ),
        onRefresh: () => _doFetchOrders()
      );
    }

    if (_orders.length == 0 && !_fetchDone) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
        child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: _orders.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: createOrderListHeader(_orders[index]),
                subtitle: createOrderListSubtitle(_orders[index]),
                onTap: () {
                  // store order_pk
                  _storeOrderPk(_orders[index].id);

                  // navigate to detail page
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (context) => OrderDetailPage())
                  );
                } // onTab
              );
            } // itemBuilder
        ),
        onRefresh: () => _doFetchOrders(),
    );
  }

  @override
  void initState() {
    super.initState();
    _doFetchOrders();
    _getDrawerForUser();
    _getTitle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title != null ? _title : ''),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: _drawer,
    );
  }
}
