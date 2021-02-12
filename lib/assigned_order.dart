import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'assignedorder_products.dart';
import 'assignedorder_activity.dart';
import 'assignedorder_documents.dart';
// import 'quotation.dart';
import 'assignedorder_workorder.dart';
import 'assignedorders_list.dart';
import 'customer_history.dart';
import 'models.dart';
import 'utils.dart';

BuildContext localContext;


Future<AssignedOrder> fetchAssignedOrder(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorder/$assignedorderPk/detail_device/?json');
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  if (response.statusCode == 200) {
    return AssignedOrder.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load assigned order');
}

Future<bool> reportStartCode(http.Client client, StartCode startCode) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorder/$assignedorderPk/report_statuscode/');
  final authHeaders = getHeaders(newToken.token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'statuscode_pk': startCode.id,
  };

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  // return
  if (response.statusCode == 401) {
    return false;
  }

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}

Future<bool> reportEndCode(http.Client client, EndCode endCode) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorder/$assignedorderPk/report_statuscode/');
  final authHeaders = getHeaders(newToken.token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'statuscode_pk': endCode.id,
  };

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  // return
  if (response.statusCode == 401) {
    return false;
  }

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}

Future<bool> reportNoWorkorderFinished(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorder/$assignedorderPk/no_workorder_finished/');
  final authHeaders = getHeaders(newToken.token);
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

  // return
  if (response.statusCode == 401) {
    return false;
  }

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}

class AssignedOrderPage extends StatefulWidget {
  @override
  _AssignedOrderPageState createState() => _AssignedOrderPageState();
}

class _AssignedOrderPageState extends State<AssignedOrderPage> {
  AssignedOrder _assignedOrder;
  bool _saving = false;

  // orderlines
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

    for (int i = 0; i < _assignedOrder.order.orderLines.length; ++i) {
      Orderline orderline = _assignedOrder.order.orderLines[i];

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

  // infolines
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

    for (int i = 0; i < _assignedOrder.order.infoLines.length; ++i) {
      Infoline infoline = _assignedOrder.order.infoLines[i];

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
        Column(children: [
          createTableHeaderCell('Open')
        ])
      ],
    ));

    for (int i = 0; i < _assignedOrder.order.documents.length; ++i) {
      OrderDocument document = _assignedOrder.order.documents[i];

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
        Column(children: [
          IconButton(
            icon: Icon(Icons.view_agenda, color: Colors.red),
            onPressed: () async {
              String url = await getUrl(document.url);
              launch(url);
            },
          )
        ]),
      ]));
    }

    return createTable(rows);
  }

  _startCodePressed(StartCode startCode) async {
    // report started
    setState(() {
      _saving = true;
    });

    bool result = await reportStartCode(http.Client(), startCode);

    if (!result) {
      setState(() {
        _saving = false;
      });

      displayDialog(localContext, 'Error', 'Error starting order');
      return;
    }

    // refresh assignedOrder
    _assignedOrder = await fetchAssignedOrder(http.Client());

    // reload screen
    setState(() {
      _saving = false;
    });
  }

  _endCodePressed(EndCode endCode) async {
    // report ended
    setState(() {
      _saving = true;
    });

    bool result = await reportEndCode(http.Client(), endCode);

    if (!result) {
      setState(() {
        _saving = false;
      });

      displayDialog(localContext, 'Error', 'Error ending order');
      return;
    }

    // refresh assignedOrder
    _assignedOrder = await fetchAssignedOrder(http.Client());

    // reload screen
    setState(() {
      _saving = false;
    });
  }

  _customerHistoryPressed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('customer_id', _assignedOrder.customer.id);

    Navigator.push(context,
        new MaterialPageRoute(
            builder: (context) => CustomerHistorytPage())
    );
  }

  _activityPressed() {
    Navigator.push(context,
        new MaterialPageRoute(
            builder: (context) => AssignedOrderActivityPage())
    );
  }

  _materialsPressed() {
    Navigator.push(context,
        new MaterialPageRoute(
            builder: (context) => AssignedOrderProductPage())
    );
  }

  _documentsPressed() {
    Navigator.push(context,
        new MaterialPageRoute(
            builder: (context) => AssignedOrderDocumentPage())
    );
  }

  _signWorkorderPressed() {
    Navigator.push(context,
        new MaterialPageRoute(
            builder: (context) => AssignedOrderWorkOrderPage())
    );
  }

  _noWorkorderPressed() async {
    setState(() {
      _saving = true;
    });

    bool result = await reportNoWorkorderFinished(http.Client());

    if (!result) {
      setState(() {
        _saving = false;
      });

      displayDialog(localContext, 'Error', 'Error ending order');
      return;
    }

    // reload screen
    setState(() {
      _saving = false;
    });

    // go to order list
    Navigator.pushReplacement(context,
        new MaterialPageRoute(
            builder: (context) => AssignedOrdersListPage())
    );
  }

  // _quotationPressed() {
  //   Navigator.push(context,
  //       new MaterialPageRoute(
  //           builder: (context) => QuotationPage())
  //   );
  // }

  Widget _buildButtons() {
    // if not started, only show first startCode as a button
    if (!_assignedOrder.isStarted) {
      StartCode startCode = _assignedOrder.startCodes[0];

      return new Container(
        child: new Column(
          children: <Widget>[
            RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: new Text(startCode.description),
              onPressed: () => _saving ? null : _startCodePressed(startCode),
            ),
          ],
        ),
      );
    }

    if (_assignedOrder.isStarted) {
      // started, show 'Register time/km', 'Register materials', and 'Manage documents' and 'Finish order'
      RaisedButton customerHistoryButton = createBlueRaisedButton(
          'Customer history', _customerHistoryPressed);
      RaisedButton activityButton = createBlueRaisedButton(
          'Register time/km', _activityPressed);
      RaisedButton materialsButton = createBlueRaisedButton(
          'Register materials', _materialsPressed);
      RaisedButton documentsButton = createBlueRaisedButton(
          'Manage documents', _documentsPressed);

      EndCode endCode = _assignedOrder.endCodes[0];
      RaisedButton finishButton = RaisedButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: new Text(endCode.description),
        onPressed: () => _saving ? null : _endCodePressed(endCode),
      );

      RaisedButton signWorkorderButton = RaisedButton(
        color: Colors.red,
        textColor: Colors.white,
        child: new Text('Sign workorder'),
        onPressed: _saving ? null : _signWorkorderPressed,
      );

      RaisedButton noWorkorderButton = RaisedButton(
        color: Colors.red,
        textColor: Colors.white,
        child: new Text('No workorder'),
        onPressed: _saving ? null : _noWorkorderPressed,
      );

      // RaisedButton quotationButton = RaisedButton(
      //   color: Colors.blue,
      //   textColor: Colors.white,
      //   child: new Text('Quotation'),
      //   onPressed: _saving ? null : _quotationPressed,
      // );

      // no ended yet, show a subset of the buttons
      if (!_assignedOrder.isEnded) {
        return new Container(
          child: new Column(
            children: <Widget>[
              customerHistoryButton,
              activityButton,
              materialsButton,
              documentsButton,
              Divider(),
              finishButton,
            ],
          ),
        );
      }

      // ended, show all buttons
      return new Container(
        child: new Column(
          children: <Widget>[
            customerHistoryButton,
            activityButton,
            materialsButton,
            documentsButton,
            Divider(),
            finishButton,
            Divider(),
            signWorkorderButton,
            noWorkorderButton,
            // quotationButton,
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    localContext = context;

    return Scaffold(
        appBar: AppBar(
          title: Text('Order details'),
        ),
        body: ModalProgressHUD(child: Center(
            child: FutureBuilder<AssignedOrder>(
                future: fetchAssignedOrder(http.Client()),
                // ignore: missing_return
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                            child: Text("Loading...")
                        )
                    );
                  } else {
                    AssignedOrder assignedOrder = snapshot.data;
                    _assignedOrder = assignedOrder;

                    double lineHeight = 35;
                    double leftWidth = 160;
                    return Align(
                      alignment: Alignment.topRight,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
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
                                child: Text(assignedOrder.order.orderId != null ? assignedOrder.order.orderId : ''),
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
                                child: Text(assignedOrder.order.orderType != null ? assignedOrder.order.orderType : ''),
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
                                child: Text(assignedOrder.order.orderDate != null ? assignedOrder.order.orderDate : ''),
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
                                child: Text(assignedOrder.order.orderName != null ? assignedOrder.order.orderName : ''),
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
                                child: Text(assignedOrder.order.orderName != null ? assignedOrder.order.customerId : ''),
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
                                child: Text(assignedOrder.order.orderAddress != null ? assignedOrder.order.orderAddress : ''),
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
                                child: Text(assignedOrder.order.orderPostal != null ? assignedOrder.order.orderPostal : ''),
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
                                child: Text(assignedOrder.order.orderCountryCode + '/' + assignedOrder.order.orderCity),
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
                                child: Text(assignedOrder.order.orderContact != null ? assignedOrder.order.orderContact : ''),
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
                                child: Text(assignedOrder.order.orderTel != null ? assignedOrder.order.orderTel : ''),
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
                                child: Text(assignedOrder.order.orderMobile != null ? assignedOrder.order.orderMobile : ''),
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
                                child: Text(assignedOrder.order.customerRemarks != null ? assignedOrder.order.customerRemarks : ''),
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
                                child: Text('Maintenance contract:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(assignedOrder.customer.maintenanceContract != null ? assignedOrder.customer.maintenanceContract : ''),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: lineHeight,
                                width: leftWidth,
                                padding: const EdgeInsets.all(8),
                                child: Text('Standard hours:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: lineHeight,
                                padding: const EdgeInsets.all(8),
                                child: Text(assignedOrder.customer.standardHours != null ? assignedOrder.customer.standardHours : ''),
                              ),
                            ],
                          ),
                          Divider(),
                          createHeader('Orderlines'),
                          _createOrderlinesTable(),
                          Divider(),
                          createHeader('Infolines'),
                          _createInfolinesTable(),
                          Divider(),
                          createHeader('Documents'),
                          _buildDocumentsTable(),
                          Divider(),
                          _buildButtons(),
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
