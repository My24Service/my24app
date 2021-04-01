import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';
import 'order_detail.dart';
import 'order_assign.dart';


Future<Orders> fetchOrdersUnAssigned(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final String token = newToken.token;
  final url = await getUrl('/order/order/dispatch_list_unassigned/?sorting=default&page=1');
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
  bool _error = false;

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

  _doFetchOrdersUnAssigned() async {
    setState(() {
      _fetchDone = false;
      _error = false;
    });

    try {
      Orders result = await fetchOrdersUnAssigned(http.Client());

      setState(() {
        _fetchDone = true;
        _orders = result.results;
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
        ), onRefresh: () => _doFetchOrdersUnAssigned(),
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
                          'orders.unassigned.button_assign'.tr(),
                          () => _navAssignOrder(_orders[index].id)
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
        title: Text('orders.unassigned.app_bar_title'.tr()),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: _drawer,
    );
  }
}
