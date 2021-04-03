import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';


Future<Customer> fetchCustomer(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final customerPk = prefs.getInt('customer_pk');
  final url = await getUrl('/customer/customer/$customerPk/');
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  if (response.statusCode == 200) {
    return Customer.fromJson(json.decode(response.body));
  }

  throw Exception('customers.detail.exception_fetch'.tr());
}

Future<Orders> fetchOrderHistory(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final customerPk = prefs.getInt('customer_pk');
  final String token = newToken.token;
  String url = await getUrl('/order/order/past/?customer_relation=$customerPk');

  final response = await client.get(
      url,
      headers: getHeaders(token)
  );

  if (response.statusCode == 200) {
    Orders results = Orders.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('customers.detail.exception_fetch_orders'.tr());
}


class CustomerDetailPage extends StatefulWidget {
  @override
  _CustomerDetailPageState createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  Customer _customer;
  bool _saving = false;
  List<Order> _orderHistory = [];
  bool _inAsyncCall = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _doFetchCustomer();
    await _doFetchOrderHistory();
  }

  _doFetchCustomer() async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    try {
      Customer customer = await fetchCustomer(http.Client());

      setState(() {
        _inAsyncCall = false;
        _customer = customer;
      });
    } catch(e) {
      setState(() {
        _inAsyncCall = false;
        _error = true;
      });
    }
  }

  _doFetchOrderHistory() async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    try {
      Orders result = await fetchOrderHistory(http.Client());

      setState(() {
        _orderHistory = result.results;
        _inAsyncCall = false;
      });
    } catch(e) {
      setState(() {
        _inAsyncCall = false;
        _error = true;
      });
    }
  }

  Widget _createWorkorderText(Order order) {
    if (order.workorderPdfUrl != null && order.workorderPdfUrl != '') {
      return createBlueElevatedButton(
        'customers.detail.button_open_workorder'.tr(),
        () => launchURL(order.workorderPdfUrl)
      );
    }

    return Text('-');
  }

  // order lines
  Widget _createHistoryTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(
          children:[
            createTableHeaderCell('orders.info_order_id'.tr())
          ]
        ),
        Column(
            children:[
              createTableHeaderCell('orders.info_order_date'.tr())
            ]
        ),
        Column(
            children:[
              createTableHeaderCell('orders.info_order_type'.tr())
            ]
        ),
        Column(
            children:[
              createTableHeaderCell('customers.detail.info_workorder'.tr())
            ]
        )
      ],
    ));

    for (int i = 0; i < _orderHistory.length; ++i) {
      Order order = _orderHistory[i];

      rows.add(
          TableRow(
              children: [
                Column(
                    children:[
                      createTableColumnCell(order.orderId)
                    ]
                ),
                Column(
                    children:[
                      createTableColumnCell(order.orderDate)
                    ]
                ),
                Column(
                    children:[
                      createTableColumnCell(order.orderType)
                    ]
                ),
                Column(
                    children:[
                      _createWorkorderText(order)
                    ]
                ),
              ]
          )
      );
    }

    return createTable(rows);
  }

  Widget _showMainView() {
    if (_error) {
      return RefreshIndicator(
        child: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('customers.detail.exception_fetch'.tr())
              ],
            )
        ), onRefresh: () => _doFetchCustomer(),
      );
    }

    if (_customer == null && _inAsyncCall) {
      return Center(child: CircularProgressIndicator());
    }

    return Align(
        alignment: Alignment.topRight,
        child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              createHeader('customers.detail.header_customer'.tr()),
              Table(
                children: [
                  TableRow(
                      children: [
                        Text('customers.info_customer_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_customer.customerId),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_name'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_customer.name),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_address'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_customer.address),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_postal'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_customer.postal),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_country_city'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_customer.countryCode + '/' + _customer.city),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_contact'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_customer.contact),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_tel'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_customer.tel),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_mobile'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_customer.mobile),
                      ]
                  ),
                  TableRow(
                      children: [
                        Divider(),
                        SizedBox(height: 10),
                      ]
                  ),
                ],
              ),
              Divider(),
              createHeader('customers.detail.header_order_history'.tr()),
              _createHistoryTable(),
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('customers.detail.app_bar_title'.tr()),
        ),
        body: ModalProgressHUD(
            child: Center(
              child: _showMainView()
            )
        , inAsyncCall: _saving)
    );
  }
}
