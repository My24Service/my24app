import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';


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

class OrderDetailPage extends StatefulWidget {
  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Order _order;
  bool _saving = false;

  // order lines
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

  // info lines
  Widget _createInfolinesTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(
            children:[
              createTableHeaderCell('Info')
            ]
        ),
      ],

    ));

    for (int i = 0; i < _order.infoLines.length; ++i) {
      Infoline infoline = _order.infoLines[i];

      rows.add(
          TableRow(
              children: [
                Column(
                    children:[
                      createTableColumnCell(infoline.info)
                    ]
                ),
              ]
          )
      );
    }

    return createTable(rows);
  }

  // documents
  Widget _buildDocumentsTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('Name')
        ]),
        Column(children: [
          createTableHeaderCell('Description')
        ]),
        Column(children: [
          createTableHeaderCell('Document')
        ]),
      ],
    ));

    // documents
    for (int i = 0; i < _order.documents.length; ++i) {
      OrderDocument document = _order.documents[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell(document.name)
            ]
        ),
        Column(
            children: [
              createTableColumnCell(document.description)
            ]
        ),
        Column(
            children: [
              createTableColumnCell(document.file.split('/').last)
            ]
        ),
      ]));
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Order details'),
        ),
        body: ModalProgressHUD(child: Center(
            child: FutureBuilder<Order>(
                future: fetchOrder(http.Client()),
                builder: (BuildContext context, AsyncSnapshot<Order> snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                            child: Text("Loading...")
                        )
                    );
                  } else {
                    _order = snapshot.data;

                    return Align(
                      alignment: Alignment.topRight,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          createHeader('Order'),
                          Table(
                            children: [
                              TableRow(
                                children: [
                                  Text('Order ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.orderId != null ? _order.orderId : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Order type:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.orderType != null ? _order.orderType : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Order date:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.orderDate != null ? _order.orderDate : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Divider(),
                                  SizedBox(height: 10),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Customer:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.orderName != null ? _order.orderName : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Customer ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.orderName != null ? _order.customerId : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.orderAddress != null ? _order.orderAddress : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Postal:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.orderPostal != null ? _order.orderPostal : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Country/City:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.orderCountryCode + '/' + _order.orderCity),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Contact:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.orderContact != null ? _order.orderContact : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Tel:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.orderTel != null ? _order.orderTel : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Mobile:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.orderMobile != null ? _order.orderMobile : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('Remaks customer:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_order.customerRemarks != null ? _order.customerRemarks : '')
                                ]
                              )
                            ],
                          ),
                          Divider(),
                          createHeader('Order lines'),
                          _createOrderlinesTable(),
                          Divider(),
                          createHeader('Info lines'),
                          _createInfolinesTable(),
                          Divider(),
                          createHeader('Documents'),
                          _buildDocumentsTable(),
                          Divider(),
                          createHeader('Status history'),
                          _createStatusView(),
                          Divider(),
                          createBlueElevatedButton(
                              _order.workorderPdfUrl != null &&
                              _order.workorderPdfUrl != '' ?
                              'Open workorder (PDF)' : 'No workorder',
                              () => launchURL(_order.workorderPdfUrl))
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
