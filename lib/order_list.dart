import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';
import 'order_detail.dart';
import 'order_edit_form.dart';


Future<bool> _deleteOrder(http.Client client, Order order) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/order/order/${order.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<Orders> fetchOrders(http.Client client, { query=''}) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final String token = newToken.token;
  String url = await getUrl('/order/order/?orders=&page=1');
  if (query != '') {
    url += '&q=$query';
  }

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
  bool _isPlanning = false;
  var _searchController = TextEditingController();
  bool _searchShown = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _setIsPlanning();
    await _doFetchOrders();
    await _getDrawerForUser();
    await  _getTitle();
  }

  _setIsPlanning() async {
    final String submodel = await getUserSubmodel();

    setState(() {
      _isPlanning = submodel == 'planning_user';
    });
  }

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

  _getDrawerForUser() async {
    Widget drawer = await getDrawerForUser(context);

    setState(() {
      _drawer = drawer;
    });
  }

  _getTitle() async {
    String title = await getOrderListTitleForUser();

    setState(() {
      _title = title;
    });
  }

  _navEditOrder(int orderPk) {
    _storeOrderPk(orderPk);

    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => OrderEditFormPage())
    );
  }

  _doDelete(Order order) async {
    bool result = await _deleteOrder(http.Client(), order);

    // fetch and rebuild widgets
    if (result) {
      createSnackBar(context, 'orders.snackbar_deleted'.tr());

      _doFetchOrders();
    } else {
      displayDialog(context,
        'generic.error_dialog_title'.tr(),
        'orders.error_deleting_dialog_content'.tr()
      );
    }
  }

  _showDeleteDialog(Order order, BuildContext context) {
    showDeleteDialog(
      'orders.delete_dialog_title'.tr(),
      'orders.delete_dialog_content'.tr(),
      context, () => _doDelete(order));
  }

  _doSearch(String query) async {
    Orders result = await fetchOrders(http.Client(), query: query);

    setState(() {
      _searchShown = false;
      _fetchDone = true;
      _orders = result.results;
    });
  }

  Row _showSearchRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 220, child:
          TextField(
            controller: _searchController,
          ),
        ),
        createBlueElevatedButton(
            'generic.action_search'.tr(),
            () => _doSearch(_searchController.text)
        ),
      ],
    );
  }

  Row _getListButtons(Order order) {
    Row row;

    if(_isPlanning) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'generic.action_edit'.tr(),
              () => _navEditOrder(order.id)
          ),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'generic.action_delete'.tr(),
              () => _showDeleteDialog(order, context),
              primaryColor: Colors.red),
        ],
      );
    } else {
      row = Row();
    }

    return row;
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
                        Text('orders.notice_no_orders'.tr())
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
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
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
                  _getListButtons(_orders[index]),
                  SizedBox(height: 10)
                ],
              );
            } // itemBuilder
        ),
        onRefresh: () => _doFetchOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title != null ? _title : ''),
      ),
      body: Container(
        child: Column(
          children: [
            _showSearchRow(),
            SizedBox(height: 20),
            Expanded(child: _buildList()),
          ]
        )
      ),
      drawer: _drawer,
    );
  }
}
