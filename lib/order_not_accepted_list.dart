import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';
import 'order_detail.dart';
import 'order_document.dart';
import 'order_edit_form.dart';


Future<bool> acceptOrder(http.Client client, int orderPk) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final String token = newToken.token;
  final url = await getUrl('/order/order/$orderPk/set_order_accepted/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {};

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  if (response.statusCode == 200) {
    return true;
  }

  return null;
}

Future<bool> deleteOrder(http.Client client, Order order) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/order/order/${order.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<Orders> fetchNotAcceptedOrders(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final String token = newToken.token;
  final url = await getUrl('/order/order/get_all_for_customer_not_accepted/');
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

class OrderNotAcceptedListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderNotAcceptedState();
  }
}

class _OrderNotAcceptedState extends State<OrderNotAcceptedListPage> {
  List<Order> _orders = [];
  bool _fetchDone = false;
  Widget _drawer;
  bool _isPlanning = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _setIsPlanning();
    await _doFetchNotAcceptedOrders();
    await _getDrawerForUser();

  }

  _setIsPlanning() async {
    final String submodel = await getUserSubmodel();

    setState(() {
      _isPlanning = submodel == 'planning_user';
    });
  }

  _getDrawerForUser() async {
    Widget drawer = await getDrawerForUser(context);

    setState(() {
      _drawer = drawer;
    });
  }

  _storeOrderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_pk', pk);
  }

  _doFetchNotAcceptedOrders() async {
    setState(() {
      _fetchDone = false;
    });

    Orders result = await fetchNotAcceptedOrders(http.Client());

    setState(() {
      _fetchDone = true;
      _orders = result.results;
    });
  }

  _doDelete(Order order) async {
    bool result = await deleteOrder(http.Client(), order);

    // fetch and rebuild widgets
    if (result) {
      createSnackBar(context, 'orders.snackbar_deleted'.tr());

      _doFetchNotAcceptedOrders();
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

  _navEditOrder(int orderPk) {
    _storeOrderPk(orderPk);

    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => OrderEditFormPage())
    );
  }

  _navDocuments(int orderPk) {
    _storeOrderPk(orderPk);

    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => OrderDocumentPage())
    );
  }

  _doAcceptOrder(int quotationPk) async {
    final bool result = await acceptOrder(http.Client(), quotationPk);

    if (result) {
      createSnackBar(context, 'orders.not_yet_accepted.snackbar_accepted'.tr());
      await _doFetchNotAcceptedOrders();
    } else {
      displayDialog(context,
        'generic.error_dialog_title'.tr(),
        'orders.not_yet_accepted.error_accepting_dialog_content'.tr());
    }
  }

  Row _getButtonRow(Order order) {
    Row row;

    if (_isPlanning) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'orders.not_yet_accepted.button_accept'.tr(),
              () => _doAcceptOrder(order.id)
          ),
        ],
      );
    } else {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'orders.not_yet_accepted.button_edit'.tr(),
              () => _navEditOrder(order.id)
          ),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'orders.not_yet_accepted.button_documents'.tr(),
              () => _navDocuments(order.id)),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'orders.not_yet_accepted.button_delete'.tr(),
              () => _showDeleteDialog(order, context),
              primaryColor: Colors.red),
        ],
      );
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
        onRefresh: () => _doFetchNotAcceptedOrders()
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
                      onTap: () {
                        // store order_pk
                        _storeOrderPk(_orders[index].id);

                        // navigate to detail page
                        Navigator.push(context,
                          new MaterialPageRoute(builder: (context) => OrderDetailPage())
                        );
                      } // onTab
                    ),
                    SizedBox(height: 10),
                    _getButtonRow(_orders[index]),
                    SizedBox(height: 10)
                  ]
              );
            } // itemBuilder
        ),
        onRefresh: () => _doFetchNotAcceptedOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('orders.not_yet_accepted.app_bar_title'.tr()),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: _drawer,
    );
  }
}
