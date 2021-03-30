import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';


Future<bool> deleteAssignedOrderActivity(http.Client client, AssignedOrderActivity activity) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/mobile/assignedorderactivity/${activity.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<AssignedOrderActivities> _fetchAssignedOrderActivity(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorderactivity/?assigned_order=$assignedorderPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return AssignedOrderActivities.fromJson(json.decode(response.body));
  }

  throw Exception('assigned_orders.activity.exception_fetch'.tr());
}

Future<bool> storeAssignedOrderActivity(http.Client client, AssignedOrderActivity activity) async {
  SlidingToken newToken = await refreshSlidingToken(client);

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

  var _startWorkHourController = TextEditingController();
  var _endWorkHourController = TextEditingController();
  var _travelToController = TextEditingController();
  var _travelBackController = TextEditingController();
  var _distanceToController = TextEditingController();
  var _distanceBackController = TextEditingController();

  var _workStartMin = '00';
  var _workEndMin = '00';
  var _travelToMin = '00';
  var _travelBackMin = '00';

  AssignedOrderActivities _assignedOrderActivities;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  _doDelete(AssignedOrderActivity activity) async {
    setState(() {
      _saving = true;
    });

    bool result = await deleteAssignedOrderActivity(http.Client(), activity);

    // fetch and rebuild widgets
    if (result) {
      createSnackBar(context, 'assigned_orders.activity.snackbar_deleted'.tr());

      await _fetchAssignedOrderActivity(http.Client());
      setState(() {
        _saving = false;
      });
    }
  }

  _showDeleteDialog(AssignedOrderActivity activity, BuildContext context) {
    showDeleteDialog(
      'assigned_orders.activity.delete_dialog_title'.tr(),
      'assigned_orders.activity.delete_dialog_content'.tr(),
      context, () => _doDelete(activity)
    );
  }

  Widget _buildActivityTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('assigned_orders.activity.info_work_start_end'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.activity.info_travel_to_back'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.activity.info_distance_to_back'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_delete'.tr())
        ])
      ],
    ));

    // products
    for (int i = 0; i < _assignedOrderActivities.results.length; ++i) {
      AssignedOrderActivity activity = _assignedOrderActivities.results[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell(activity.workStart + '/' + activity.workEnd)
            ]
        ),
        Column(
            children: [
              createTableColumnCell(activity.travelTo + '/' + activity.travelBack)
            ]
        ),
        Column(
            children: [
              createTableColumnCell("${activity.distanceTo}/${activity.distanceBack}")
            ]
        ),
        Column(children: [
          IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(activity, context);
              },
          )
        ]),
      ]));
    }

    return createTable(rows);
  }

  _buildWorkStartMinutes() {
    return DropdownButton<String>(
      value: _workStartMin,
      items: <String>['00', '15', '30', '45'].map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _workStartMin = newValue;
        });
      },
    );
  }

  _buildWorkEndMinutes() {
    return DropdownButton<String>(
      value: _workEndMin,
      items: <String>['00', '15', '30', '45'].map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _workEndMin = newValue;
        });
      },
    );
  }

  _buildTravelToMinutes() {
    return DropdownButton<String>(
      value: _travelToMin,
      items: <String>['00', '15', '30', '45'].map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _travelToMin = newValue;
        });
      },
    );
  }

  _buildTravelBackMinutes() {
    return DropdownButton<String>(
      value: _travelBackMin,
      items: <String>['00', '15', '30', '45'].map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _travelBackMin = newValue;
        });
      },
    );
  }

  Widget _buildForm() {
    final double leftWidth = 100;
    final double rightWidth = 50;

    return Column(
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          createHeader('assigned_orders.activity.header_new_activity'.tr()),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('assigned_orders.activity.label_start_work'.tr()),
                  Row(
                    children: [
                      Container(
                        width: leftWidth,
                        child: TextFormField(
                            controller: _startWorkHourController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'assigned_orders.activity.validator_start_work_hour'.tr();
                              }
                              return null;
                            },
                            decoration: new InputDecoration(
                                labelText: 'assigned_orders.activity.info_hours'.tr()
                            ),
                        ),
                      ),
                      Container(
                          width: rightWidth,
                          child: _buildWorkStartMinutes()
                      )
                    ],
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('assigned_orders.activity.label_end_work'.tr()),
                  Row(
                    children: [
                      Container(
                        width: leftWidth,
                        child: TextFormField(
                            controller: _endWorkHourController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'assigned_orders.activity.validator_end_work_hour'.tr();
                              }
                              return null;
                            },
                            decoration: new InputDecoration(
                                labelText: 'assigned_orders.activity.info_hours'.tr()
                            )
                        ),
                      ),
                      Container(
                          width: rightWidth,
                          child: _buildWorkEndMinutes()
                      )
                    ],
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('assigned_orders.activity.label_travel_to'.tr()),
                  Row(
                    children: [
                      Container(
                        width: leftWidth,
                        child: TextFormField(
                            controller: _travelToController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'assigned_orders.activity.validator_travel_to_hours'.tr();
                              }
                              return null;
                            },
                            decoration: new InputDecoration(
                                labelText: 'assigned_orders.activity.info_hours'.tr()
                            )
                        ),
                      ),
                      Container(
                          width: rightWidth,
                          child: _buildTravelToMinutes()
                      )
                    ],
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('assigned_orders.activity.label_travel_back'.tr()),
                  Row(
                    children: [
                      Container(
                        width: leftWidth,
                        child: TextFormField(
                            controller: _travelBackController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'assigned_orders.activity.validator_travel_back_hours'.tr();
                              }
                              return null;
                            },
                            decoration: new InputDecoration(
                                labelText: 'assigned_orders.activity.info_hours'.tr()
                            )
                        ),
                      ),
                      Container(
                          width: rightWidth,
                          child: _buildTravelBackMinutes()
                      )
                    ],
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text('assigned_orders.activity.label_distance_to'.tr()),
          Container(
            width: 150,
            child: TextFormField(
                controller: _distanceToController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'assigned_orders.activity.validator_distance_to'.tr();
                  }
                  return null;
                }),
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('assigned_orders.activity.label_distance_back'.tr()),
          Container(
            width: 150,
            child: TextFormField(
                controller: _distanceBackController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'assigned_orders.activity.validator_distance_back'.tr();
                  }
                  return null;
                }),
          ),
          SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue, // background
              onPrimary: Colors.white, // foreground
            ),
            child: Text('assigned_orders.activity.button_add_activity'.tr()),
            onPressed: () async {
              if (this._formKey.currentState.validate()) {
                this._formKey.currentState.save();

                // only continue if something is set
                if (_startWorkHourController.text == '0' && _workStartMin == '00' &&
                    _endWorkHourController.text == '0' && _workEndMin == '00' &&
                    _travelToController.text == '0' && _travelToMin == '00' &&
                    _travelBackController.text == '0' && _travelBackMin == '00' &&
                    _distanceToController.text == '0' && _distanceBackController.text == '0'
                ) {
                  FocusScope.of(context).unfocus();
                  return;
                }

                AssignedOrderActivity activity = AssignedOrderActivity(
                  workStart: '${_startWorkHourController.text}:$_workStartMin:00}',
                  workEnd: '${_endWorkHourController.text}:$_workEndMin:00',
                  travelTo: '${_travelToController.text}:$_travelToMin:00',
                  travelBack: '${_travelBackController.text}:$_travelBackMin:00',
                  distanceTo: int.parse(_distanceToController.text),
                  distanceBack: int.parse(_distanceBackController.text),
                );

                setState(() {
                  _saving = true;
                });

                bool result = await storeAssignedOrderActivity(http.Client(), activity);

                setState(() {
                  _saving = false;
                });

                if (result) {
                  createSnackBar(context, 'assigned_orders.activity.snackbar_added'.tr());

                  // reset fields
                  _startWorkHourController.text = '';
                  _endWorkHourController.text = '';
                  _travelToController.text = '';
                  _travelBackController.text = '';
                  _distanceToController.text = '';
                  _distanceBackController.text = '';

                  _assignedOrderActivities = await _fetchAssignedOrderActivity(http.Client());
                  FocusScope.of(context).unfocus();
                } else {
                  displayDialog(context,
                    'generic.error_dialog_title'.tr(),
                    'assigned_orders.activity.error_dialog_content'.tr()
                  );
                }
              }
            },
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('assigned_orders.activity.app_bar_title'.tr()),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ModalProgressHUD(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(    // new line
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        child: _buildForm(),
                      ),
                      Divider(),
                      FutureBuilder<AssignedOrderActivities>(
                        future: _fetchAssignedOrderActivity(http.Client()),
                        // ignore: missing_return
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Container(
                                child: Center(
                                    child: Text('generic.loading'.tr())
                                )
                            );
                          } else {
                            _assignedOrderActivities = snapshot.data;
                            return Container(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  _buildActivityTable(),
                                ],
                              ),
                            );
                          }
                        }
                      ),
                    ],
                  ),
                ),
              ),
            )
          ), inAsyncCall: _saving)
        )
    );
  }
}
