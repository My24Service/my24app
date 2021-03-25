import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'utils.dart';
import 'order_detail.dart';
import 'order_assign.dart';


Future<Orders> fetchOrdersUnAssigned(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // make call
  final String token = newToken.token;
  final url = await getUrl('/order/order/dispatch_list_unassigned/?sorting=default&page=1');
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
    await refreshTokenBackground(client);
    Orders results = Orders.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('Failed to load orders: ${response.statusCode}, ${response.body}');
}

class OrdersUnAssignedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderState();
  }
}

class _OrderState extends State<OrdersUnAssignedPage> {
  List<Order> _orders = [];
  bool _fetchDone = false;
  Widget _drawer;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _doFetchOrdersUnAssigned();
    await _getDrawerForUser();
  }

  _storeOrderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_pk', pk);
  }

  _doFetchOrdersUnAssigned() async {
    Orders result = await fetchOrdersUnAssigned(http.Client());

    setState(() {
      _fetchDone = true;
      _orders = result.results;
    });
  }

  _getDrawerForUser() async {
    Widget drawer = await getDrawerForUser(context);

    setState(() {
      _drawer = drawer;
    });
  }

  _navAssignOrder(int orderPk) async {
    await _storeOrderPk(orderPk);

    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => OrderAssignPage())
    );
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
        onRefresh: () => _doFetchOrdersUnAssigned()
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
              return Column(
                children: [
                  ListTile(
                      title: createOrderListHeader(_orders[index]),
                      subtitle: createOrderListSubtitle(_orders[index]),
                      onTap: () async {
                        // store order_pk
                        await _storeOrderPk(_orders[index].id);

                        // navigate to detail page
                        Navigator.push(context,
                            new MaterialPageRoute(builder: (context) => OrderDetailPage())
                        );
                      } // onTab
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      createBlueElevatedButton(
                          'Assign', () => _navAssignOrder(_orders[index].id)
                      ),
                    ],
                  ),
                  SizedBox(height: 10)
                ],
              );
            } // itemBuilder
        ),
        onRefresh: () => _doFetchOrdersUnAssigned(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unassigned orders'),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: _drawer,
    );
  }
}
