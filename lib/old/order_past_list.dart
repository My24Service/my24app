import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';
import 'order_detail.dart';


Future<Orders> fetchOrders(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int userId = prefs.getInt('user_id');
  final String token = newToken.token;
  final url = await getUrl('/order/order/past/?page=1');
  final response = await client.get(
    url,
    headers: getHeaders(token)
  );

  if (response.statusCode == 200) {
    Orders results = Orders.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('orders.exception_fetch'.tr());
}

class OrderPastListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderPastState();
  }
}

class _OrderPastState extends State<OrderPastListPage> {
  List<Order> _orders = [];
  String _customerName = '';
  bool _fetchDone = false;
  Widget _drawer;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _doFetchPastOrders();
    await _getDrawerForUser();
  }

  void _getDrawerForUser() async {
    Widget drawer = await getDrawerForUser(context);

    setState(() {
      _drawer = drawer;
    });
  }

  _storeOrderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_pk', pk);
  }

  _doFetchPastOrders() async {
    setState(() {
      _fetchDone = false;
      _error = false;
    });

    try {
      Orders result = await fetchOrders(http.Client());

      setState(() {
        _fetchDone = true;
        _orders = result.results;

        if (_orders.length > 0) {
          _customerName = _orders[0].orderName;
        }
      });
    } catch(e) {
      setState(() {
        _fetchDone = true;
        _error = true;
      });
    }
  }

  Widget _buildList() {
    if (_error) {
      return RefreshIndicator(
        child: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('orders.exception_fetch'.tr())
              ],
            )
        ), onRefresh: () => _doFetchPastOrders(),
      );
    }

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
                        Text('orders.notice_no_orders'.tr())
                      ],
                    )
                )
              ]
          )
        ),
        onRefresh: () => _doFetchPastOrders()
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
        onRefresh: () => _doFetchPastOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'orders.past.app_bar_title'.tr(namedArgs: {'customerName': _customerName})
        ),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: _drawer,
    );
  }
}
