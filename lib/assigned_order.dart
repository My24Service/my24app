import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'utils.dart';

BuildContext localContext;

Future<AssignedOrder> fetchAssignedOrder(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

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

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorder/$assignedorderPk/detail_device/?json');
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

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorder/$assignedorderPk/detail_device/?json');
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

class AssignedOrderPage extends StatefulWidget {
  @override
  _AssignedOrderPageState createState() => _AssignedOrderPageState();
}

class _AssignedOrderPageState extends State<AssignedOrderPage> {
  Widget _createOrderlinewTable(AssignedOrder assignedOrder) {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(
          children:[
            Text('Product', style: TextStyle(fontWeight: FontWeight.bold))
          ]
        ),
        Column(
            children:[
              Text('Location', style: TextStyle(fontWeight: FontWeight.bold))
            ]
        ),
        Column(
            children:[
              Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold))
            ]
        )
      ],

    ));

    // orderlines
    for (int i = 0; i < assignedOrder.order.orderLines.length; ++i) {
      Orderline orderline = assignedOrder.order.orderLines[i];

      rows.add(
          TableRow(
              children: [
                Column(
                    children:[
                      Text(orderline.product)
                    ]
                ),
                Column(
                    children:[
                      Text(orderline.location)
                    ]
                ),
                Column(
                    children:[
                      Text(orderline.remarks)
                    ]
                ),
              ]
          )
      );
    }

    return Table(
        border: TableBorder.all(),
        children: rows
    );
  }

  _startCodePressed(StartCode startCode, AssignedOrder assignedOrder) {
    // report started

    // reload streen on success

  }

  _endCodePressed(endCode, AssignedOrder assignedOrder) {
    // report ended

    // reload streen on success

  }

  _activityPressed() {

  }

  _materialsPressed() {

  }
  _documentsPressed() {

  }

  Widget _buildButtons(AssignedOrder assignedOrder) {
    // if not started, only show first startCode as a button
    if (!assignedOrder.isStarted) {
      StartCode startCode = assignedOrder.startCodes[0];

      return new Container(
        child: new Column(
          children: <Widget>[
            RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: new Text(startCode.description),
              onPressed: _startCodePressed(startCode, assignedOrder),
            ),
          ],
        ),
      );
    }

    // started, show 'Register time/km', 'Register materials', and 'Manage documents' and 'Finish order'
    RaisedButton activityButton = RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      child: new Text('Register time/km'),
      onPressed: _activityPressed,
    );

    RaisedButton materialsButton = RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      child: new Text('Register materials'),
      onPressed: _materialsPressed,
    );

    RaisedButton documentsButton = RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      child: new Text('Manage documents'),
      onPressed: _documentsPressed,
    );

    EndCode endCode = assignedOrder.endCodes[0];
    RaisedButton finishButton = RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      child: new Text(endCode.description),
      onPressed: _endCodePressed(endCode, assignedOrder),
    );

    return new Container(
      child: new Column(
        children: <Widget>[
          activityButton,
          materialsButton,
          documentsButton,
          finishButton,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    localContext = context;

    return Scaffold(
        appBar: AppBar(
          title: Text('Order details'),
        ),
        body: Center(
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
                    print(assignedOrder);
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
                                child: Text(assignedOrder.order.orderId),
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
                                child: Text(assignedOrder.order.orderType),
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
                                child: Text(assignedOrder.order.orderDate),
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
                                child: Text(assignedOrder.order.orderName),
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
                                child: Text(assignedOrder.order.orderAddress),
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
                                child: Text(assignedOrder.order.orderPostal),
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
                                child: Text(assignedOrder.order.orderContact),
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
                                child: Text(assignedOrder.order.orderTel),
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
                                child: Text(assignedOrder.order.orderMobile),
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
                                child: Text(assignedOrder.order.customerRemarks),
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
                                child: Text(assignedOrder.customer.maintenanceContract),
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
                                child: Text(assignedOrder.customer.standardHours),
                              ),
                            ],
                          ),
                          Divider(),
                          _createOrderlinewTable(assignedOrder),
                          Divider(),
                          _buildButtons(assignedOrder),
                        ]
                      )
                    );
                  } // else
                } // builder
            )
        )
    );
  }
}
