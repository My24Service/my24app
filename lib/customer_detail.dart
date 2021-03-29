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
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

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

  throw Exception('Failed to load customer');
}

Future<Orders> fetchOrderHistory(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // make call
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

  throw Exception('Failed to load orders: ${response.statusCode}, ${response.body}');
}


class CustomerDetailPage extends StatefulWidget {
  @override
  _CustomerDetailPageState createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  Customer _customer;
  bool _saving = false;
  List<Order> _orderHistory = [];

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _doFetchOrderHistory();
  }

  _doFetchOrderHistory() async {
    Orders result = await fetchOrderHistory(http.Client());

    setState(() {
      _orderHistory = result.results;
    });
  }

  Widget _createWorkorderText(Order order) {
    if (order.workorderPdfUrl != null && order.workorderPdfUrl != '') {
      return createBlueElevatedButton('Open', () => launchURL(order.workorderPdfUrl));
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
            createTableHeaderCell('Order ID')
          ]
        ),
        Column(
            children:[
              createTableHeaderCell('Date')
            ]
        ),
        Column(
            children:[
              createTableHeaderCell('Type')
            ]
        ),
        Column(
            children:[
              createTableHeaderCell('Workorder')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Customer details'),
        ),
        body: ModalProgressHUD(child: Center(
            child: FutureBuilder<Customer>(
                future: fetchCustomer(http.Client()),
                builder: (BuildContext context, AsyncSnapshot<Customer> snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                            child: Text("Loading...")
                        )
                    );
                  } else {
                    _customer = snapshot.data;

                    return Align(
                      alignment: Alignment.topRight,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          createHeader('Customer'),
                          Table(
                            children: [
                              TableRow(
                                children: [
                                  Text('Customer ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_customer.customerId),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_customer.name),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_customer.address),
                                ]
                              ),
                              TableRow(
                                  children: [
                                    Text('Postal:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(_customer.postal),
                                  ]
                              ),
                              TableRow(
                                  children: [
                                    Text('Country/City:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(_customer.countryCode + '/' + _customer.city),
                                  ]
                              ),
                              TableRow(
                                  children: [
                                    Text('Contact:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(_customer.contact),
                                  ]
                              ),
                              TableRow(
                                  children: [
                                    Text('Tel:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(_customer.tel),
                                  ]
                              ),
                              TableRow(
                                  children: [
                                    Text('Mobile:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          createHeader('Order history'),
                          _createHistoryTable(),
                        ]
                      )
                    );
                  } // else
                } // builder
            )
        ), inAsyncCall: _saving)
    );
  }
}
