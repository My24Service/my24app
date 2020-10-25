import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'utils.dart';
import 'main_dev.dart';
import 'order_detail.dart';
import 'order_form.dart';
import 'order_list.dart';
import 'order_past_list.dart';
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

  Widget _createHeader(Order order) {
    return Column(
      children: [
        Row(
          children: [
            Text('Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${order.orderDate}')
          ]
        ),
        Row(
          children: [
            Text('Order ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${order.orderId}')
          ],
        )
      ]
    );
  }

  Widget _createSubtitle(Order order) {
    return Table(
      children: [
        TableRow(
          children: [
            Text('Order type: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${order.orderType}')
          ]
        ),
        TableRow(
          children: [
            Text('Last status: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${order.lastStatusFull}')
          ]
        )
      ],
    );
  }

  showDeleteDialog(Order order) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context, false);
      },
    );
    Widget deleteButton = FlatButton(
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

  Widget _buildList() {
    if (_orders.length == 0 && _fetchDone) {
      return RefreshIndicator(
        child: Center(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(child: Text('\n\n\nNo orders.'))
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
                      title: _createHeader(_orders[index]),
                      subtitle: _createSubtitle(_orders[index]),
                      onTap: () {
                        // store order_pk
                        _storeOrderPk(_orders[index].id);

                        // navigate to detail page
                        Navigator.push(context,
                          new MaterialPageRoute(builder: (context) => OrderDetailPage())
                        );
                      } // onTab
                    ),
                    Row(
                      children: [
                        RaisedButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: new Text('Edit'),
                          onPressed: () {
                            // store order_pk
                            _storeOrderPk(_orders[index].id);

                            Navigator.push(context,
                              new MaterialPageRoute(builder: (context) => OrderEditFormPage())
                            );
                          }
                        ),
                        SizedBox(width: 10),
                        createBlueRaisedButton('Photos', () => {
                          Navigator.push(context,
                              new MaterialPageRoute(builder: (context) => OrderDocumentPage())
                          )
                        }),
                        SizedBox(width: 10),
                        RaisedButton(
                            color: Colors.red,
                            textColor: Colors.white,
                            child: new Text('Delete'),
                            onPressed: () => {
                              showDeleteDialog(_orders[index])
                            }
                        ),
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

  Widget _createDrawerHeader() {
    return Container(
      height: 60.0,
      child: DrawerHeader(
          child: Text('  Options', style: TextStyle(color: Colors.white)),
          decoration: BoxDecoration(
              color: Colors.blue
          ),
          margin: EdgeInsets.all(4.10),
          padding: EdgeInsets.all(.5)
      ),
    );
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
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            _createDrawerHeader(),
            ListTile(
              title: Text('Orders'),
              onTap: () {
                // close the drawer
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => OrderListPage())
                );
              },
            ),
            ListTile(
              title: Text('Orders processing'),
              onTap: () {
                // close the drawer
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => OrderNotAcceptedListPage())
                );
              },
            ),
            ListTile(
              title: Text('Past orders'),
              onTap: () {
                // close the drawer
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => OrderPastListPage())
                );
              },
            ),
            ListTile(
              title: Text('New order'),
              onTap: () {
                // close the drawer
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => OrderFormPage())
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                // close the drawer
                Navigator.pop(context);

                bool loggedOut = await logout();

                if (loggedOut == true) {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => My24App())
                  );
                }
              }, // onTap
            ),

          ],
        ),
      ),
    );
  }
}
