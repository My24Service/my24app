import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'utils.dart';


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

class AssignedOrderPage extends StatelessWidget {
  Widget _buildProductLines(AssignedOrder assignedOrder) {
    double lineHeight = 30;
    double width = 120;

    return Row(
      children: <Widget>[
        Container(
          height: lineHeight,
          width: width,
          padding: const EdgeInsets.all(8),
          child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          height: lineHeight,
          width: width,
          padding: const EdgeInsets.all(8),
          child: Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          height: lineHeight,
          width: width,
          padding: const EdgeInsets.all(8),
          child: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    double leftWidth = 150;
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
                          _buildProductLines(assignedOrder),
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
