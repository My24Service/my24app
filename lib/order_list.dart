import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'utils.dart';
import 'main.dart';
import 'order_detail.dart';
import 'order_form.dart';
import 'order_past_list.dart';
import 'order_not_accepted_list.dart';


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
  String _customerName;
  bool _fetchDone = false;

  _storeOrderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_pk', pk);
  }

  void _doFetch() async {
    Orders result = await fetchOrders(http.Client());

    if (result == null) {
      // redirect to login page?
      displayDialog(context, 'Error', 'Error orders');
      return;
    }

    setState(() {
      _fetchDone = true;
      _orders = result.results;
      _customerName = _orders[0].orderName;
    });
  }

  Widget _createHeader(Order order) {
    return Column(
      children: [
        Row(
          children: [
            Text('Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${order.orderDate}')
          ]
        ),
        Row(
          children: [
            Text('Order ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${order.orderId}')
          ],
        )
      ]
    );
  }

  Widget _createSubtitle(Order order) {
    return Table(
      children: [
        TableRow(
          children: [
            Text('Order type: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${order.orderType}')
          ]
        ),
        TableRow(
          children: [
            Text('Last status: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${order.lastStatusFull}')
          ]
        )
      ],
    );
  }

  Widget _buildList() {
    if (_orders.length == 0 && _fetchDone) {
      return RefreshIndicator(
        child: Center(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(child: Text('\n\n\nNo orders.'))
              ]
          )
        ),
        onRefresh: _getData
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
                title: _createHeader(_orders[index]),
                subtitle: _createSubtitle(_orders[index]),
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
        onRefresh: _getData,
    );
  }

  Future<void> _getData() async {
    setState(() {
      _doFetch();
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
    _doFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.all(0),
          children: <Widget>[
            createDrawerHeader(),
            ListTile(
              title: Text('Orders'),
              onTap: () {
                // close the drawer
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => OrderListPage())
                );
              },
            ),
            ListTile(
              title: Text('Orders processing'),
              onTap: () {
                // close the drawer
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => OrderNotAcceptedListPage())
                );
              },
            ),
            ListTile(
              title: Text('Past orders'),
              onTap: () {
                // close the drawer
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => OrderPastListPage())
                );
              },
            ),
            ListTile(
              title: Text('New order'),
              onTap: () {
                // close the drawer
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => OrderFormPage())
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                // close the drawer
                Navigator.pop(context);

                bool loggedOut = await logout();

                if (loggedOut == true) {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => My24App())
                  );
                }
              }, // onTap
            ),

          ],
        ),
      ),
    );
  }
}
