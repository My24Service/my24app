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

  throw Exception('orders.detail.exception_fetch'.tr());
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
            createTableHeaderCell('generic.info_equipment'.tr())
          ]
        ),
        Column(
            children:[
              createTableHeaderCell('generic.info_location'.tr())
            ]
        ),
        Column(
            children:[
              createTableHeaderCell('generic.info_remarks'.tr())
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
              createTableHeaderCell('orders.info_infoline'.tr())
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
          createTableHeaderCell('generic.info_name'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_description'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('orders.info_document'.tr())
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
          title: Text('orders.detail.app_bar_title'.tr()),
        ),
        body: ModalProgressHUD(child: Center(
            child: FutureBuilder<Order>(
                future: fetchOrder(http.Client()),
                builder: (BuildContext context, AsyncSnapshot<Order> snapshot) {
                  if (snapshot.hasError) {
                    Container(
                        child: Center(
                            child: Text(
                                'orders.detail.exception_fetch'.tr()
                            )
                        )
                    );
                  }

                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                            child: Text('generic.loading'.tr())
                        )
                    );
                  } else {
                    _order = snapshot.data;

                    return Align(
                      alignment: Alignment.topRight,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          createHeader('orders.info_order'.tr()),
                          Table(
                            children: [
                              TableRow(
                                children: [
                                  Text('orders.info_order_id'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text(_order.orderId != null ? _order.orderId : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('orders.info_order_type'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text(_order.orderType != null ? _order.orderType : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('orders.info_order_date'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
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
                                  Text('orders.info_customer'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text(_order.orderName != null ? _order.orderName : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('orders.info_customer_id'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text(_order.orderName != null ? _order.customerId : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('orders.info_address'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text(_order.orderAddress != null ? _order.orderAddress : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('orders.info_postal'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text(_order.orderPostal != null ? _order.orderPostal : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('orders.info_country_city'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text(_order.orderCountryCode + '/' + _order.orderCity),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('orders.info_contact'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text(_order.orderContact != null ? _order.orderContact : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('orders.info_tel'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text(_order.orderTel != null ? _order.orderTel : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('orders.info_mobile'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text(_order.orderMobile != null ? _order.orderMobile : ''),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('orders.info_order_customer_remarks'.tr(),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  Text(_order.customerRemarks != null ? _order.customerRemarks : '')
                                ]
                              )
                            ],
                          ),
                          Divider(),
                          createHeader('orders.header_orderlines'.tr()),
                          _createOrderlinesTable(),
                          Divider(),
                          createHeader('orders.header_infolines'.tr()),
                          _createInfolinesTable(),
                          Divider(),
                          createHeader('orders.header_documents'.tr()),
                          _buildDocumentsTable(),
                          Divider(),
                          createHeader('orders.header_status_history'.tr()),
                          _createStatusView(),
                          Divider(),
                          createBlueElevatedButton(
                              _order.workorderPdfUrl != null &&
                              _order.workorderPdfUrl != '' ?
                              'orders.button_open_workorder'.tr() :
                              'orders.button_no_workorder'.tr(),
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
