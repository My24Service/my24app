import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'models.dart';
import 'utils.dart';
import 'assigned_order.dart';


BuildContext localContext;

Future<bool> deleteAssignedOrderActivity(http.Client client, AssignedOrderActivity activity) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  final url = await getUrl('/mobile/assignedorderactivity/${activity.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<AssignedOrderActivities> fetchAssignedOrderActivity(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorderactivity/?assigned_order=$assignedorderPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return AssignedOrderActivities.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load assigned order activity');
}

Future<bool> storeAssignedOrderActivity(http.Client client, AssignedOrderActivity activity) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    // do nothing
    return false;
  }

  // store it in the API
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final String token = newToken.token;
  final url = await getUrl('/mobile/assignedorderactivity/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'assigned_order': assignedorderPk,
    'distance_to': activity.distanceTo,
    'distance_back': activity.distanceBack,
    'travel_to': activity.travelTo,
    'travel_back': activity.travelBack,
    'work_start': activity.workStart,
    'work_end': activity.workEnd,
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

  if (response.statusCode == 201) {
    return true;
  }

  return false;
}

class AssignedOrderActivityPage extends StatefulWidget {
  @override
  _AssignedOrderActivityPageState createState() =>
      _AssignedOrderActivityPageState();
}

class _AssignedOrderActivityPageState extends State<AssignedOrderActivityPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _productIdentifierController = TextEditingController();
  var _productNameController = TextEditingController();
  var _productAmountController = TextEditingController();

  AssignedOrderActivities _assignedOrderActivities;

  @override
  void initState() {
    super.initState();
  }

  showDeleteDialog(AssignedOrderActivity activity) {
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
      title: Text("Delete activity"),
      content: Text("Do you want to delete this activity?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    var result = showDialog(
      context: localContext,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((dialogResult) async {
      if (dialogResult) {
          bool result = await deleteAssignedOrderActivity(http.Client(), activity);

          // fetch and refresh screen
          if (result) {
            await fetchAssignedOrderActivity(http.Client());
            setState(() {});
          }
      }
    });
  }

  Widget _buildActivityTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          Text('Work start/end', style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        Column(children: [
          Text('Travel to/back', style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        Column(children: [
          Text('Distance to/back', style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        Column(children: [
          Text('Delete', style: TextStyle(fontWeight: FontWeight.bold))
        ])
      ],
    ));

    // products
    for (int i = 0; i < _assignedOrderActivities.results.length; ++i) {
      AssignedOrderActivity activity = _assignedOrderActivities.results[i];

      rows.add(TableRow(children: [
        Column(children: [Text(activity.workStart + '/' + activity.workEnd)]),
        Column(children: [Text(activity.travelTo + '/' + activity.travelBack)]),
        Column(children: [Text("${activity.distanceTo}/${activity.distanceBack}")]),
        Column(children: [
          IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDeleteDialog(activity);
              },
          )
        ]),
      ]));
    }

    return Table(border: TableBorder.all(), children: rows);
  }

  Widget _buildForm() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('New activity'),
          Text('Product'),
          TextFormField(
              readOnly: true,
              controller: _productNameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              }),
          SizedBox(
            height: 10.0,
          ),
          Text('Identifier'),
          TextFormField(
              readOnly: true,
              controller: _productIdentifierController,
              validator: (value) {
                return null;
              }),
          SizedBox(
            height: 10.0,
          ),
          Text('Amount'),
          TextFormField(
              controller: _productAmountController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter an amount';
                }
                return null;
              }),
          SizedBox(
            height: 10.0,
          ),
          RaisedButton(
            child: Text('Submit'),
            onPressed: () async {
              if (this._formKey.currentState.validate()) {
                this._formKey.currentState.save();

                AssignedOrderActivity activity = AssignedOrderActivity(
                );

                bool result = await storeAssignedOrderActivity(http.Client(), activity);

                if (result) {
                  // reset fields
                  _productAmountController.text = '';
                  _productNameController.text = '';
                  _productIdentifierController.text = '';

                  _assignedOrderActivities = await fetchAssignedOrderActivity(http.Client());
                  setState(() {});

                } else {
                  displayDialog(context, 'Error', 'Error storing material');
                }
              }
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          RaisedButton(
            child: Text('Back to order'),
            onPressed: () {
              Navigator.push(context,
                  new MaterialPageRoute(
                      builder: (context) => AssignedOrderPage())
              );
            },
          )
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    localContext = context;
    
    return Scaffold(
        appBar: AppBar(
          title: Text('Activity'),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(    // new line
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildForm(),
                    Divider(),
                    FutureBuilder<AssignedOrderActivities>(
                      future: fetchAssignedOrderActivity(http.Client()),
                      // ignore: missing_return
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Container(
                              child: Center(
                                  child: Text("Loading...")
                              )
                          );
                        } else {
                          _assignedOrderActivities = snapshot.data;
                          return _buildActivityTable();
                        }
                      }
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
            ),
          )
        )
    );
  }
}
