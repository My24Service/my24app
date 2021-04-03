import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import 'assignedorder_materials.dart';
import 'assignedorder_activity.dart';
import 'assignedorder_documents.dart';
import 'assignedorder_workorder.dart';
import 'assignedorders_list.dart';
import 'assigned_order_customer_history.dart';
import 'models.dart';
import 'utils.dart';


Future<AssignedOrder> fetchAssignedOrder(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorder/$assignedorderPk/detail_device/?json');
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  if (response.statusCode == 200) {
    AssignedOrder assignedOrder = AssignedOrder.fromJson(json.decode(response.body));

    // store customerRelation
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customer_relation', assignedOrder.order.customerRelation);

    return assignedOrder;
  }

  throw Exception('assigned_orders.detail.exception_fetch'.tr());
}

Future<bool> reportStartCode(http.Client client, StartCode startCode) async {
  SlidingToken newToken = await refreshSlidingToken(client);

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

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}

Future<bool> reportEndCode(http.Client client, EndCode endCode) async {
  SlidingToken newToken = await refreshSlidingToken(client);

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

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}

Future<bool> reportNoWorkorderFinished(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

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

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}

Future<Map> createExtraOrder(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final String token = newToken.token;
  final url = await getUrl('/mobile/assignedorder/$assignedorderPk/create_extra_order/');
  final authHeaders = getHeaders(token);
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

  if (response.statusCode == 200) {
    return json.decode(response.body);
  }

  return {'result': false};
}



class AssignedOrderPage extends StatefulWidget {
  @override
  _AssignedOrderPageState createState() => _AssignedOrderPageState();
}

class _AssignedOrderPageState extends State<AssignedOrderPage> {
  AssignedOrder _assignedOrder;
  bool _inAsyncCall = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _doFetchAssignedOrder();
  }

  _doFetchAssignedOrder() async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    try {
      AssignedOrder assignedOrder = await fetchAssignedOrder(http.Client());

      setState(() {
        _inAsyncCall = false;
        _assignedOrder = assignedOrder;
      });
    } catch(e) {
      setState(() {
        _inAsyncCall = false;
        _error = true;
      });
    }
  }

  // orderlines
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
              createTableHeaderCell('assigned_orders.detail.info_info'.tr())
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
          createTableHeaderCell('generic.info_name'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_description'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_document'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_open'.tr())
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
      _inAsyncCall = true;
    });

    bool result = await reportStartCode(http.Client(), startCode);

    if (!result) {
      createSnackBar(context, 'assigned_orders.detail.snackbar_started'.tr());

      setState(() {
        _inAsyncCall = false;
      });

      displayDialog(context,
        'generic.error_dialog_title'.tr(),
        'assigned_orders.detail.error_dialog_content_started'.tr()
      );
      return;
    }

    // refresh assignedOrder
    _assignedOrder = await fetchAssignedOrder(http.Client());

    // reload screen
    setState(() {
      _inAsyncCall = false;
    });
  }

  _endCodePressed(EndCode endCode) async {
    // report ended
    setState(() {
      _inAsyncCall = true;
    });

    bool result = await reportEndCode(http.Client(), endCode);

    if (!result) {
      createSnackBar(context, 'assigned_orders.detail.snackbar_ended'.tr());

      setState(() {
        _inAsyncCall = false;
      });

      displayDialog(context,
        'generic.error_dialog_title'.tr(),
        'assigned_orders.detail.error_dialog_content_ended'.tr()
      );
      return;
    }

    // refresh assignedOrder
    _assignedOrder = await fetchAssignedOrder(http.Client());

    // reload widgets
    setState(() {
      _inAsyncCall = false;
    });
  }

  _customerHistoryPressed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('customer_id', _assignedOrder.customer.id);

    Navigator.push(context,
        new MaterialPageRoute(
            builder: (context) => CustomerHistoryPage())
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
            builder: (context) => AssignedOrderMaterialPage())
    );
  }

  _documentsPressed() {
    Navigator.push(context,
        new MaterialPageRoute(
            builder: (context) => AssignedOrderDocumentPage())
    );
  }

  _extraWorkButtonPressed() {
    // set up the buttons
    Widget cancelButton = TextButton(
        child: Text('generic.action_cancel'.tr()),
        onPressed: () => Navigator.pop(context, false)
    );
    Widget deleteButton = TextButton(
        child: Text('assigned_orders.detail.button_create_extra_order'.tr()),
        onPressed: () => Navigator.pop(context, true)
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('assigned_orders.detail.dialog_extra_order_title'.tr()),
      content: Text('assigned_orders.detail.dialog_extra_order_content'.tr()),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (_) {
        return alert;
      },
    ).then((dialogResult) async {
      if (dialogResult == null) return;

      if (dialogResult) {
        setState(() {
          _inAsyncCall = true;
        });

        // create new order
        Map result = await createExtraOrder(http.Client());

        if (result['result'] == false) {
          displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'assigned_orders.detail.error_dialog_content_extra_order'.tr()
          );
          setState(() {
            _inAsyncCall = false;
          });

          return;
        }

        // store in prefs
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('assignedorder_pk', result['new_assigned_order']);

        setState(() {
          _inAsyncCall = false;
        });

        // navigate to new assignedorder
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) =>
                AssignedOrderPage()
            )
        );
      }
    });
  }

  _signWorkorderPressed() {
    Navigator.push(context,
        new MaterialPageRoute(
            builder: (context) => AssignedOrderWorkOrderPage())
    );
  }

  _noWorkorderPressed() async {
    setState(() {
      _inAsyncCall = true;
    });

    bool result = await reportNoWorkorderFinished(http.Client());

    if (!result) {
      setState(() {
        _inAsyncCall = false;
      });

      displayDialog(context,
        'generic.error_dialog_title'.tr(),
        'assigned_orders.detail.error_dialog_content_ending'.tr()
      );
      return;
    }

    // reload screen
    setState(() {
      _inAsyncCall = false;
    });

    // go to order list
    Navigator.pushReplacement(context,
        new MaterialPageRoute(
            builder: (context) => AssignedOrdersListPage())
    );
  }

  Widget _buildButtons() {
    // if not started, only show first startCode as a button
    if (!_assignedOrder.isStarted) {
      StartCode startCode = _assignedOrder.startCodes[0];

      return new Container(
        child: new Column(
          children: <Widget>[
            createBlueElevatedButton(startCode.description, _inAsyncCall ? null :
              () => _startCodePressed(startCode))
          ],
        ),
      );
    }

    if (_assignedOrder.isStarted) {
      // started, show 'Register time/km', 'Register materials', and 'Manage documents' and 'Finish order'
      ElevatedButton customerHistoryButton = createBlueElevatedButton(
          'assigned_orders.detail.button_customer_history'.tr(), _customerHistoryPressed);
      ElevatedButton activityButton = createBlueElevatedButton(
          'assigned_orders.detail.button_register_time_km'.tr(), _activityPressed);
      ElevatedButton materialsButton = createBlueElevatedButton(
          'assigned_orders.detail.button_register_materials'.tr(), _materialsPressed);
      ElevatedButton documentsButton = createBlueElevatedButton(
          'assigned_orders.detail.button_manage_documents'.tr(), _documentsPressed);

      EndCode endCode = _assignedOrder.endCodes[0];

      ElevatedButton finishButton = createBlueElevatedButton(
          endCode.description, _inAsyncCall ? null : () => _endCodePressed(endCode));

      ElevatedButton extraWorkButton = createBlueElevatedButton(
          'assigned_orders.detail.button_extra_work'.tr(), _extraWorkButtonPressed,
          primaryColor: Colors.red);
      ElevatedButton signWorkorderButton = createBlueElevatedButton(
          'assigned_orders.detail.button_sign_workorder'.tr(), _signWorkorderPressed,
          primaryColor: Colors.red);
      ElevatedButton noWorkorderButton = createBlueElevatedButton(
          'assigned_orders.detail.button_no_workorder'.tr(), _noWorkorderPressed,
          primaryColor: Colors.red);

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
            extraWorkButton,
            signWorkorderButton,
            noWorkorderButton,
            // quotationButton,
          ],
        ),
      );
    }
  }

  _showAlsoAssigned(AssignedOrder assignedOrder) {
    if (assignedOrder.assignedUserData.length == 0) {
      return Table(children: [
        TableRow(
          children: [
            Column(children: [
              createTableColumnCell('assigned_orders.detail.info_no_one_else_assigned'.tr())
            ])
          ]
        )
      ]);
    }

    List<TableRow> users = [];

    for (int i=0; i<assignedOrder.assignedUserData.length; i++) {
      users.add(TableRow(
          children: [
            Column(children: [
              createTableColumnCell(assignedOrder.assignedUserData[i].fullName)
            ])
          ]
      )
      );
    }

    return Table(children: users);
  }

  Widget _showMainListView() {
    if (_error) {
      return RefreshIndicator(
        child: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('assigned_orders.detail.exception_fetch'.tr())
              ],
            )
        ), onRefresh: () => _doFetchAssignedOrder(),
      );
    }

    if (_assignedOrder == null && _inAsyncCall) {
      return Center(child: CircularProgressIndicator());
    }

    return Align(
        alignment: Alignment.topRight,
        child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Table(
                children: [
                  TableRow(
                      children: [
                        Text('orders.info_order_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.orderId != null ? _assignedOrder.order.orderId : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_type'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.orderType != null ? _assignedOrder.order.orderType : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_date'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_assignedOrder.order.orderDate != null ? _assignedOrder.order.orderDate : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Divider(),
                        SizedBox(height: 10)
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_customer'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.orderName != null ? _assignedOrder.order.orderName : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_customer_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.orderName != null ? _assignedOrder.order.customerId : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_address'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.orderAddress != null ? _assignedOrder.order.orderAddress : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_postal'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.orderPostal != null ? _assignedOrder.order.orderPostal : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_country_city'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.orderCountryCode + '/' + _assignedOrder.order.orderCity),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_contact',
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.orderContact != null ? _assignedOrder.order.orderContact : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_tel'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.orderTel != null ? _assignedOrder.order.orderTel : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_mobile'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.orderMobile != null ? _assignedOrder.order.orderMobile : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('generic.info_email'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.orderEmail != null ? _assignedOrder.order.orderEmail : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_customer_remarks'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.order.customerRemarks != null ? _assignedOrder.order.customerRemarks : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Divider(),
                        SizedBox(height: 10)
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('assigned_orders.detail.info_maintenance_contract'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.customer.maintenanceContract != null ? _assignedOrder.customer.maintenanceContract : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('assigned_orders.detail.info_standard_hours'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(_assignedOrder.customer.standardHours != null ? _assignedOrder.customer.standardHours : '-'),
                      ]
                  )
                ],
              ),
              Divider(),
              createHeader('assigned_orders.detail.header_also_assigned'.tr()),
              _showAlsoAssigned(_assignedOrder),
              Divider(),
              createHeader('assigned_orders.detail.header_orderlines'.tr()),
              _createOrderlinesTable(),
              Divider(),
              createHeader('assigned_orders.detail.header_infolines'.tr()),
              _createInfolinesTable(),
              Divider(),
              createHeader('assigned_orders.detail.header_documents'.tr()),
              _buildDocumentsTable(),
              Divider(),
              _buildButtons(),
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('assigned_orders.detail.app_bar_title'.tr()),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ModalProgressHUD(child: Center(
            child: _showMainListView()
          ), inAsyncCall: _inAsyncCall)
        )
    );
  }
}
