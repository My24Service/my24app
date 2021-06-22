import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/api/mobile_api.dart';

class ActivityWidget extends StatefulWidget {
  final AssignedOrderActivities activities;
  final int assignedOrderPk;

  ActivityWidget({
    Key key,
    this.activities,
    this.assignedOrderPk
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ActivityWidgetState(
      activities: activities,
      assignedOrderPk: assignedOrderPk
  );
}

class _ActivityWidgetState extends State<ActivityWidget> {
  final AssignedOrderActivities activities;
  final int assignedOrderPk;

  _ActivityWidgetState({
    @required this.activities,
    @required this.assignedOrderPk,
  }) : super();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _startWorkHourController = TextEditingController();
  var _endWorkHourController = TextEditingController();
  var _travelToController = TextEditingController();
  var _travelBackController = TextEditingController();
  var _distanceToController = TextEditingController();
  var _distanceBackController = TextEditingController();
  var _extraWorkHourController = TextEditingController();
  var _extraWorkDescriptionController = TextEditingController();

  var _workStartMin = '00';
  var _workEndMin = '00';
  var _travelToMin = '00';
  var _travelBackMin = '00';
  var _extraWorkMin = '00';

  DateTime _activityDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  bool _inAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child: _showMainView(context),
        inAsyncCall: _inAsyncCall
    );
  }

  Widget _showMainView(BuildContext context) {
    return Container(
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
                    child: _buildForm(context),
                  ),
                  Divider(),
                  createHeader('assigned_orders.activity.info_header_table'.tr()),
                  _buildActivityTable(context),
                ]
              )
            )
          )
        )
    );
  }

  _doDelete(BuildContext context, AssignedOrderActivity activity) async {
    final bloc = BlocProvider.of<ActivityBloc>(context);

    bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
    bloc.add(ActivityEvent(
        status: ActivityEventStatus.DELETE,
        value: activity.id
    ));
  }

  _showDeleteDialog(AssignedOrderActivity activity, BuildContext context) {
    showDeleteDialogWrapper(
      'assigned_orders.activity.delete_dialog_title'.tr(),
      'assigned_orders.activity.delete_dialog_content'.tr(),
      context, () => _doDelete(context, activity)
    );
  }

  Widget _buildActivityTable(BuildContext context) {
    if(activities.results.length == 0) {
      return buildEmptyListFeedback();
    }

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
          createTableHeaderCell('assigned_orders.activity.label_extra_work'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.activity.label_activity_date'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_delete'.tr())
        ])
      ],
    ));

    // products
    for (int i = 0; i < activities.results.length; ++i) {
      AssignedOrderActivity activity = activities.results[i];

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
        Column(
            children: [
              createTableColumnCell(activity.extraWork)
            ]
        ),
        Column(
            children: [
              createTableColumnCell("${activity.activityDate}")
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

  _selectActivityDate(BuildContext context) async {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        theme: DatePickerTheme(
            headerColor: Colors.orange,
            backgroundColor: Colors.blue,
            itemStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            doneStyle: TextStyle(color: Colors.white, fontSize: 16)
        ),
        onChanged: (date) {
        }, onConfirm: (date) {
          setState(() {
            _activityDate = date;
          });
        },
        currentTime: DateTime.now(),
        locale: LocaleType.en
    );
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

  _buildExtraWorkMinutes() {
    return DropdownButton<String>(
      value: _extraWorkMin,
      items: <String>['00', '15', '30', '45'].map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _extraWorkMin = newValue;
        });
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    final double leftWidth = 100;
    final double rightWidth = 50;
    final double spaceBetween = 50;

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
            height: spaceBetween,
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
            height: spaceBetween,
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
            height: spaceBetween,
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
            height: spaceBetween,
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
            height: spaceBetween,
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
          // extra work
          SizedBox(
            height: spaceBetween,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('assigned_orders.activity.label_extra_work'.tr()),
                  Row(
                    children: [
                      Container(
                        width: leftWidth,
                        child: TextFormField(
                            controller: _extraWorkHourController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              return null;
                            },
                            decoration: new InputDecoration(
                                labelText: 'assigned_orders.activity.info_hours'.tr()
                            )
                        ),
                      ),
                      Container(
                          width: rightWidth,
                          child: _buildExtraWorkMinutes()
                      )
                    ],
                  ),
                  Container(
                    width: 200,
                    child: TextFormField(
                        controller: _extraWorkDescriptionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        validator: (value) {
                          return null;
                        },
                        decoration: new InputDecoration(
                            labelText: 'assigned_orders.activity.info_description'.tr()
                        )
                    ),
                  )

                ],
              )
            ],
          ),
          SizedBox(
            height: spaceBetween,
          ),
          Text('assigned_orders.activity.label_activity_date'.tr()),
          Container(
            width: 150,
            child: createBlueElevatedButton(
                "${_activityDate.toLocal()}".split(' ')[0],
                    () => _selectActivityDate(context),
                primaryColor: Colors.white,
                onPrimary: Colors.black),
          ),
          SizedBox(
            height: spaceBetween,
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

                // extra work
                String extraWork;
                String extraWorkDescription;

                if (_extraWorkDescriptionController.text != '') {
                  if (_extraWorkHourController.text == '' && _extraWorkMin == '00') {
                    displayDialog(context,
                      'generic.error_dialog_title'.tr(),
                      'assigned_orders.activity.error_dialog_content_extra_work'.tr()
                    );

                    return;
                  }

                  extraWork = '${_extraWorkHourController.text}:$_extraWorkMin:00}';
                  extraWorkDescription = _extraWorkDescriptionController.text;
                }

                AssignedOrderActivity activity = AssignedOrderActivity(
                  activityDate: utils.formatDate(_activityDate),
                  workStart: '${_startWorkHourController.text}:$_workStartMin:00}',
                  workEnd: '${_endWorkHourController.text}:$_workEndMin:00',
                  travelTo: '${_travelToController.text}:$_travelToMin:00',
                  travelBack: '${_travelBackController.text}:$_travelBackMin:00',
                  distanceTo: int.parse(_distanceToController.text),
                  distanceBack: int.parse(_distanceBackController.text),
                  extraWork: extraWork,
                  extraWorkDescription: extraWorkDescription,
                );

                setState(() {
                  _inAsyncCall = true;
                });

                AssignedOrderActivity newActivity = await mobileApi.insertAssignedOrderActivity(activity, assignedOrderPk);

                setState(() {
                  _inAsyncCall = false;
                });

                if (newActivity == null) {
                  displayDialog(context,
                      'generic.error_dialog_title'.tr(),
                      'assigned_orders.activity.error_dialog_content'.tr()
                  );
                  return;
                }

                final bloc = BlocProvider.of<ActivityBloc>(context);
                bloc.add(ActivityEvent(
                    status: ActivityEventStatus.INSERTED));

              }
            },
          ),
        ],
      );
  }
}
