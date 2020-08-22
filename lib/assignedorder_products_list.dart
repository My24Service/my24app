import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'utils.dart';

BuildContext localContext;

Future<AssignedOrderProducts> fetchAssignedOrderProducts(
    http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl(
      '/mobile/assignedorderproduct/?assigned_order=$assignedorderPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return AssignedOrderProducts.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load assigned order products');
}

class AssignedOrderProductListPage extends StatefulWidget {
  @override
  _AssignedOrderProductListPageState createState() =>
      _AssignedOrderProductListPageState();
}

class _AssignedOrderProductListPageState extends State<AssignedOrderProductListPage> {
  AssignedOrderProducts _assignedOrderProducts;

  Widget _buildProductsTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          Text('Product', style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        Column(children: [
          Text('Identifier', style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        Column(children: [
          Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))
        ])
      ],
    ));

    // products
    for (int i = 0; i < _assignedOrderProducts.results.length; ++i) {
      AssignedOrderProduct product = _assignedOrderProducts.results[i];

      rows.add(TableRow(children: [
        Column(children: [Text(product.productName)]),
        Column(children: [Text(product.productIdentifier)]),
        Column(children: [Text("${product.amount}")]),
      ]));
    }

    return Table(border: TableBorder.all(), children: rows);
  }

  @override
  Widget build(BuildContext context) {
    localContext = context;

    return Scaffold(
        appBar: AppBar(
          title: Text('Materials'),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 43.0),
          child: Column(
            children: [
              _buildProductsTable()
            ],
          )
        )
    );
  }
}
