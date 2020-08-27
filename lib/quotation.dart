import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'utils.dart';

BuildContext localContext;


Future<Order> fetchOrderDetail(http.Client client) async {
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

  throw Exception('Failed to load order detail');
}

class QuotationPage extends StatefulWidget {
  @override
  _QuotationPageState createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  Order _order;
  List<QuotationProduct> _quotationProducts;

  @override
  Widget build(BuildContext context) {
    localContext = context;

    return Scaffold(
        appBar: AppBar(
          title: Text('Order details'),
        ),
        body: Center(
            child: FutureBuilder<Order>(
                future: fetchOrderDetail(http.Client()),
                // ignore: missing_return
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                            child: Text("Loading...")
                        )
                    );
                  } else {
                    Order order = snapshot.data;
                    _order = order;

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
                                    child: Text('Order ID:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderId),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Order type:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderType),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Order date:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderDate),
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
                                    child: Text('Customer:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderName),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Address:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderAddress),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Postal:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderPostal),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Country/City:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderCountryCode + '/' +
                                        order.orderCity),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Contact:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderContact),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Tel:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderTel),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Mobile:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderMobile),
                                  ),
                                ],
                              ),
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
