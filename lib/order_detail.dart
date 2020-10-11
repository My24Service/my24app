import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'utils.dart';

BuildContext localContext;


Future<Order> fetchOrder(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final orderPk = prefs.getInt('order_pk');
  final url = await getUrl('/order/order/$orderPk/');
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  if (response.statusCode == 200) {
    return Order.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load order');
}

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Order _order;
  bool _saving = false;

  Widget _createOrderlinesTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(
          children:[
            createTableHeaderCell('Product')
          ]
        ),
        Column(
            children:[
              createTableHeaderCell('Location')
            ]
        ),
        Column(
            children:[
              createTableHeaderCell('Remarks')
            ]
        )
      ],

    ));

    // orderlines
    for (int i = 0; i < _order.orderLines.length; ++i) {
      Orderline orderline = _order.orderLines[i];

      rows.add(
          TableRow(
              children: [
                Column(
                    children:[
                      createTableColumnCell(orderline.product)
                    ]
                ),
                Column(
                    children:[
                      createTableColumnCell(orderline.location)
                    ]
                ),
                Column(
                    children:[
                      createTableColumnCell(orderline.remarks)
                    ]
                ),
              ]
          )
      );
    }

    return createTable(rows);
  }

  Widget _createStatusView() {
    List<TableRow> rows = [];

    // statusses
    for (int i = 0; i < _order.statusses.length; ++i) {
      Status status = _order.statusses[i];

      rows.add(
          TableRow(
              children: [
                Column(
                    children:[
                      createTableColumnCell(status.created)
                    ]
                ),
                Column(
                    children:[
                      createTableColumnCell(status.status)
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
    localContext = context;

    return Scaffold(
        appBar: AppBar(
          title: Text('Order details'),
        ),
        body: ModalProgressHUD(child: Center(
            child: FutureBuilder<Order>(
                future: fetchOrder(http.Client()),
                // ignore: missing_return
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                            child: Text("Loading...")
                        )
                    );
                  } else {
                    _order = snapshot.data;

                    double lineHeight = 35;
                    double leftWidth = 160;
                    return Align(
                      alignment: Alignment.topRight,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          createHeader('Order'),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Order ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.orderId != null ? _order.orderId : ''),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Order type:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.orderType != null ? _order.orderType : ''),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Order date:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.orderDate != null ? _order.orderDate : ''),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Customer:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.orderName != null ? _order.orderName : ''),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Customer ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.orderName != null ? _order.customerId : ''),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.orderAddress != null ? _order.orderAddress : ''),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Postal:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.orderPostal != null ? _order.orderPostal : ''),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Country/City:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.orderCountryCode + '/' + _order.orderCity),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Contact:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.orderContact != null ? _order.orderContact : ''),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Tel:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.orderTel != null ? _order.orderTel : ''),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Mobile:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.orderMobile != null ? _order.orderMobile : ''),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Remaks customer:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(_order.customerRemarks != null ? _order.customerRemarks : ''),
                              ),
                            ],
                          ),
                          Divider(),
                          createHeader('Order lines'),
                          _createOrderlinesTable(),
                          Divider(),
                          createHeader('Status history'),
                          _createStatusView(),
                          Divider(),
                          RaisedButton(
                            onPressed: () => launchURL(_order.workorderPdfUrl),
                            child: Text(_order.workorderPdfUrl != null && _order.workorderPdfUrl != '' ? 'Open workorder' : 'No workorder'),
                          ),

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
