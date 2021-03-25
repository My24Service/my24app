import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'utils.dart';
import 'order_unassigned_list.dart';


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

Future<EngineerUsers> fetchEngineers(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final url = await getUrl('/company/engineer/?page=1');
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  if (response.statusCode == 200) {
    return EngineerUsers.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load engineers');
}

Future<bool> doAssign(http.Client client, List<int> engineerPks, String orderId) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    // do nothing
    return false;
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  // store it in the API
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String token = newToken.token;
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'order_ids': "$orderId",
  };

  int errors = 0;
  int success = 0;

  for (var i=0; i<engineerPks.length; i++) {
    final int engineerPk = engineerPks[i];
    final url = await getUrl('/mobile/assign-user-submodel/$engineerPk/');

    final response = await client.post(
      url,
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      print('Success');
      success++;
    } else {
      print('Error: ${response.statusCode}');
      errors++;
    }
  }

  print('errors: $errors, success: $success');

  // return
  if (errors == 0) {
    return true;
  }

  return false;
}


class OrderAssignPage extends StatefulWidget {
  @override
  _OrderAssignPageState createState() => _OrderAssignPageState();
}

class _OrderAssignPageState extends State<OrderAssignPage> {
  Order _order;
  bool _saving = false;

  List<EngineerUser> _engineers = [];
  List<int> _selectedEngineerPks = [];
  bool _fetchDone = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _doFetchEngineers();
  }

  _doFetchEngineers() async {
    EngineerUsers result = await fetchEngineers(http.Client());

    setState(() {
      _fetchDone = true;
      _engineers = result.results;
    });
  }

  bool _isEngineerSelected(EngineerUser engineer) {
    return _selectedEngineerPks.contains(engineer.id);
  }
  
  _createEngineersTable() {
    List<TableRow> rows = [];

    // statusses
    for (int i = 0; i < _engineers.length; ++i) {
      EngineerUser engineer = _engineers[i];

      rows.add(
          TableRow(
              children: [
                Column(
                    children:[
                      CheckboxListTile(value: _isEngineerSelected(engineer),
                          activeColor: Colors.green,
                          onChanged:(bool newValue) {
                            if (newValue) {
                              _selectedEngineerPks.add(engineer.id);
                            } else {
                              _selectedEngineerPks.remove(engineer.id);
                            }

                            setState(() {});
                          },
                          title: Text('${engineer.fullName}')
                      )
                    ]
                ),
              ]
          )
      );
    }

    rows.add(
      TableRow(
        children: [
          SizedBox(height: 20)
        ]
      )
    );

    rows.add(
        TableRow(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // background
                  onPrimary: Colors.white, // foreground
                ),
                child: Text('Assign order'),
                onPressed: () async {
                  if (_selectedEngineerPks.length == 0) {
                    displayDialog(context, 'No engineers', 'Please select one or more engineers');
                    return;
                  }

                  final bool result = await doAssign(http.Client(), _selectedEngineerPks, _order.orderId);

                  if (result) {
                    Navigator.pushReplacement(context,
                        new MaterialPageRoute(
                            builder: (context) => OrdersUnAssignedPage())
                    );
                  } else {
                    displayDialog(context, 'Error', 'Error assigning order');
                  }
                }
              )
            ]
        )
    );

    return createTable(rows);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Assign order'),
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
                          createHeader('Engineers'),
                          _createEngineersTable(),
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
