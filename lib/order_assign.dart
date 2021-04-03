import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';
import 'order_unassigned_list.dart';


Future<Order> fetchOrder(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

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

  throw Exception('orders.assign.exception_fetch'.tr());
}

Future<EngineerUsers> fetchEngineers(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final url = await getUrl('/company/engineer/?page=1');
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  if (response.statusCode == 200) {
    return EngineerUsers.fromJson(json.decode(response.body));
  }

  throw Exception('orders.assign.exception_fetch_engineers'.tr());
}

Future<bool> doAssign(http.Client client, List<int> engineerPks, String orderId) async {
  SlidingToken newToken = await refreshSlidingToken(client);

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

  for (var i=0; i<engineerPks.length; i++) {
    final int engineerPk = engineerPks[i];
    final url = await getUrl('/mobile/assign-user-submodel/$engineerPk/');

    final response = await client.post(
      url,
      body: json.encode(body),
      headers: allHeaders,
    );

    if (response.statusCode != 200) {
      errors++;
    }
  }

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
  bool _inAsyncCall = false;
  bool _error = false;

  List<EngineerUser> _engineers = [];
  List<int> _selectedEngineerPks = [];

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _doFetchOrder();
    await _doFetchEngineers();
  }

  _doFetchOrder() async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    try {
      _order = await fetchOrder(http.Client());

      setState(() {
        _inAsyncCall = false;
      });
    } catch(e) {
      setState(() {
        _inAsyncCall = false;
        _error = true;
      });
    }
  }

  _doFetchEngineers() async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    try {
      EngineerUsers result = await fetchEngineers(http.Client());

      setState(() {
        _inAsyncCall = false;
        _engineers = result.results;
      });
    } catch(e) {
      setState(() {
        _inAsyncCall = false;
        _error = true;
      });
    }
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
                child: Text('orders.assign.button_assign'.tr()),
                onPressed: () async {
                  if (_selectedEngineerPks.length == 0) {
                    displayDialog(context,
                      'orders.assign.dialog_no_engineers_selected_title'.tr(),
                      'orders.assign.dialog_no_engineers_selected_content'.tr()
                    );
                    return;
                  }

                  final bool result = await doAssign(http.Client(), _selectedEngineerPks, _order.orderId);

                  if (result) {
                    createSnackBar(context, 'orders.assign.snackbar_assigned'.tr());

                    Navigator.pushReplacement(context,
                        new MaterialPageRoute(
                            builder: (context) => OrdersUnAssignedPage())
                    );
                  } else {
                    displayDialog(context,
                      'generic.error_dialog_title'.tr(),
                      'orders.assign.error_dialog_content'.tr()
                    );
                  }
                }
              )
            ]
        )
    );

    return createTable(rows);
  }

  Widget _showMainView() {
    if (_error) {
      return RefreshIndicator(
        child: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('orders.assign.exception_fetch'.tr())
              ],
            )
        ), onRefresh: () => _doFetchOrder(),
      );
    }

    if (_order == null && _inAsyncCall) {
      return Center(child: CircularProgressIndicator());
    }

    return Align(
        alignment: Alignment.topRight,
        child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              createHeader('orders.assign.header_order'.tr()),
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
              createHeader('orders.assign.header_engineers'.tr()),
              _createEngineersTable(),
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('orders.assign.app_bar_title'.tr()),
        ),
        body: ModalProgressHUD(
                child: Center(
                  child: _showMainView()
                ), inAsyncCall: _inAsyncCall
        )
    );
  }
}
