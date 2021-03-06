import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'utils.dart';
import 'order_detail.dart';
import 'order_document.dart';
import 'order_edit_form.dart';


Future<bool> _deleteOrder(http.Client client, Order order) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  final url = await getUrl('/order/order/${order.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<Orders> _fetchNotAcceptedOrders(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // make call
  final String token = newToken.token;
  final url = await getUrl('/order/order/get_all_for_customer_not_accepted/');
  final response = await client.get(
    url,
    headers: getHeaders(token)
  );

  if (response.statusCode == 401) {
    Map<String, dynamic> reponseBody = json.decode(response.body);

    if (reponseBody['code'] == 'token_not_valid') {
      throw TokenExpiredException('token expired');
    }
  }

  if (response.statusCode == 200) {
    refreshTokenBackground(client);
    Orders results = Orders.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('Failed to load orders: ${response.statusCode}, ${response.body}');
}

class OrderNotAcceptedListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderNotAcceptedState();
  }
}

class _OrderNotAcceptedState extends State<OrderNotAcceptedListPage> {
  List<Order> _orders = [];
  bool _fetchDone = false;
  bool _saving = false;

  _storeOrderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_pk', pk);
  }

  void _doFetch() async {
    Orders result = await _fetchNotAcceptedOrders(http.Client());

    if (result == null) {
      // redirect to login page?
      displayDialog(context, 'Error', 'Error orders');
      return;
    }

    setState(() {
      _fetchDone = true;
      _orders = result.results;
    });
  }

  _showDeleteDialog(Order order) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context, false);
      },
    );
    Widget deleteButton = TextButton(
      child: Text("Delete"),
      onPressed:  () async {
        Navigator.pop(context, true);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete order"),
      content: Text("Do you want to delete this order?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((dialogResult) async {
      if (dialogResult == null) return;

      if (dialogResult) {
        setState(() {
          _saving = true;
        });

        bool result = await _deleteOrder(http.Client(), order);

        // fetch and refresh screen
        if (result) {
          _doFetch();
        } else {
          displayDialog(context, 'Error', 'Error deleting order');
        }
      }
    });
  }
  
  _navEditOrder(int orderPk) {
    _storeOrderPk(orderPk);

    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => OrderEditFormPage())
    );
  }

  _navDocuments(int orderPk) {
    _storeOrderPk(orderPk);

    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => OrderDocumentPage())
    );
  }

  Widget _buildList() {
    if (_orders.length == 0 && _fetchDone) {
      return RefreshIndicator(
        child: Center(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Text('No orders.')
                      ],
                    )
                )
              ]
          )
        ),
        onRefresh: _getData
      );
    }

    if (_orders.length == 0 && !_fetchDone) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
        child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: _orders.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                  children: [
                    ListTile(
                      title: createOrderListHeader(_orders[index]),
                      subtitle: createOrderListSubtitle(_orders[index]),
                      onTap: () {
                        // store order_pk
                        _storeOrderPk(_orders[index].id);

                        // navigate to detail page
                        Navigator.push(context,
                          new MaterialPageRoute(builder: (context) => OrderDetailPage())
                        );
                      } // onTab
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        createBlueElevatedButton(
                            'Edit',
                            () => _navEditOrder(_orders[index].id)
                        ),
                        SizedBox(width: 10),
                        createBlueElevatedButton(
                            'Documents',
                            () => _navDocuments(_orders[index].id)),
                        SizedBox(width: 10),
                        createBlueElevatedButton(
                            'Delete',
                            () => _showDeleteDialog(_orders[index]),
                            primaryColor: Colors.red),
                      ],
                    ),
                    SizedBox(height: 10)
                  ]
              );
            } // itemBuilder
        ),
        onRefresh: _getData,
    );
  }

  Future<void> _getData() async {
    setState(() {
      _doFetch();
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
    _doFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Not yet accepted orders'),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: createCustomerDrawer(context),
    );
  }
}
