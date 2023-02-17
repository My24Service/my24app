import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:my24app/core/widgets/sliver_classes.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';


class ActivityFormWidget extends BaseSliverStatelessWidget {
  final AssignedOrderActivityFormData activity;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> minutes = ['00', '05', '10', '15', '20', '25' ,'30', '35', '40', '45', '50', '55'];

  ActivityFormWidget({
    Key key,
    this.activity
  }) : super(key: key);

  @override
  SliverAppBar getAppBar(BuildContext context) {
    String title = activity.id == null ? 'assigned_orders.activity.app_bar_title_new'.tr() : 'assigned_orders.activity.app_bar_title_edit'.tr();
    GenericAppBarFactory factory = GenericAppBarFactory(
      context: context,
      title: title,
      subtitle: "",
    );
    return factory.createAppBar();
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
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
                ]
              )
            )
          )
        )
    );
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
          activity.activityDate = date;
          _updateFormData(context);
        },
        currentTime: DateTime.now(),
        locale: LocaleType.en
    );
  }

  _buildMinutes(BuildContext context, String target) {
    return DropdownButton<String>(
      value: target,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        target = newValue;
        _updateFormData(context);
      },
    );
  }

  void _toggleShowActualWork(BuildContext context) {
    activity.showActualWork = !activity.showActualWork;
    _updateFormData(context);
  }

  Widget _buildActualWork(BuildContext context) {
    final double leftWidth = 100;
    final double rightWidth = 50;

    return Visibility(
      visible: activity.showActualWork,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text('assigned_orders.activity.label_actual_work'.tr()),
              Row(
                children: [
                  Container(
                    width: leftWidth,
                    child: TextFormField(
                      controller: activity.actualWorkHourController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        return null;
                      },
                      decoration: new InputDecoration(
                          labelText: 'assigned_orders.activity.info_hours'.tr()
                      ),
                    ),
                  ),
                  Container(
                      width: rightWidth,
                      child: _buildMinutes(context, activity.actualWorkMin)
                  )
                ],
              )
            ],
          )
        ]
      )
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
                            controller: activity.workStartHourController,
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
                          child: _buildMinutes(context, activity.workStartMin)
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
                            controller: activity.workEndHourController,
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
                          child: _buildMinutes(context, activity.workEndMin)
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
                            controller: activity.travelToHourController,
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
                          child: _buildMinutes(context, activity.travelToMin)
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
                            controller: activity.travelBackHourController,
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
                          child: _buildMinutes(context, activity.travelBackMin)
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
                controller: activity.distanceToController,
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
                controller: activity.distanceBackController,
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
                            controller: activity.extraWorkHourController,
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
                          child: _buildMinutes(context, activity.extraWorkMin)
                      )
                    ],
                  ),
                  Container(
                    width: 200,
                    child: TextFormField(
                        controller: activity.extraWorkDescriptionController,
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
          createElevatedButtonColored(
              activity.showActualWork ?
              'assigned_orders.activity.label_actual_work_hide'.tr() :
              'assigned_orders.activity.label_actual_work_show'.tr(),
              _toggleShowActualWork
          ),
          _buildActualWork(context),
          SizedBox(
            height: spaceBetween,
          ),
          Text('assigned_orders.activity.label_activity_date'.tr()),
          Container(
            width: 150,
            child: createElevatedButtonColored(
                "${activity.activityDate.toLocal()}".split(' ')[0],
                () => _selectActivityDate(context),
                foregroundColor: Colors.white,
                backgroundColor: Colors.black),
          ),
          SizedBox(
            height: spaceBetween,
          ),
          createDefaultElevatedButton(
              'assigned_orders.activity.button_add_activity'.tr(),
              () => { _submitForm(context) }
          )
        ],
      );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      // only continue if something is set
      if (activity.workStartHourController.text == '0' && activity.workStartMin == '00' &&
          activity.workEndHourController.text == '0' && activity.workEndMin == '00' &&
          activity.travelToHourController.text == '0' && activity.travelToMin == '00' &&
          activity.travelBackHourController.text == '0' && activity.travelBackMin == '00' &&
          activity.distanceToController.text == '0' &&
          activity.distanceBackController.text == '0'
      ) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<ActivityBloc>(context);
      if (activity.id != null) {
        AssignedOrderActivity updatedActivity = activity.toModel();
        bloc.add(ActivityEvent(
            status: ActivityEventStatus.UPDATE,
            activity: updatedActivity
        ));
      } else {
        AssignedOrderActivity newActivity = activity.toModel();
        bloc.add(ActivityEvent(
            status: ActivityEventStatus.INSERT,
            activity: newActivity
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<ActivityBloc>(context);
    bloc.add(ActivityEvent(
        status: ActivityEventStatus.UPDATE_FORM_DATA,
        activityFormData: activity
    ));
  }

}
