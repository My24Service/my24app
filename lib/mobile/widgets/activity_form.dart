import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:my24app/core/widgets/sliver_classes.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/activity/form_data.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/models/activity/models.dart';


class ActivityFormWidget extends BaseSliverStatelessWidget {
  final int assignedOrderId;
  final AssignedOrderActivityFormData activity;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> minutes = ['00', '05', '10', '15', '20', '25' ,'30', '35', '40', '45', '50', '55'];

  ActivityFormWidget({
    Key key,
    this.assignedOrderId,
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

  void _toggleShowActualWork(BuildContext context) {
    activity.showActualWork = !activity.showActualWork;
    _updateFormData(context);
  }

  void _minuteSelectChange(BuildContext context, String newValue, String fieldName) {
    switch (fieldName) {
      case "workStartMin": {
        activity.workStartMin = newValue;
        _updateFormData(context);
      }
      break;

      case "workEndMin": {
        activity.workEndMin = newValue;
        _updateFormData(context);
      }
      break;

      case "travelToMin": {
        activity.travelToMin = newValue;
        _updateFormData(context);
      }
      break;

      case "travelBackMin": {
        activity.travelBackMin = newValue;
        _updateFormData(context);
      }
      break;

      case "extraWorkMin": {
        activity.extraWorkMin = newValue;
        _updateFormData(context);
      }
      break;

      case "actualWorkMin": {
        activity.actualWorkMin = newValue;
        _updateFormData(context);
      }
      break;

      default: {
        throw Exception("unknown field: $fieldName");
      }
    }
  }

  Widget _createHourMinRow(
      BuildContext context, TextEditingController hourController,
      String minuteSelectValue, String minuteSelectFieldName,
      {
        double leftWidth: 100, double rightWidth: 50, bool
        hourRequired: true, String hourValidationError
      }
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: leftWidth,
          child: TextFormField(
            controller: hourController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty && hourRequired) {
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
            child: DropdownButton<String>(
                value: minuteSelectValue,
                items: minutes.map((String minute) {
                  return new DropdownMenuItem<String>(
                    child: new Text(minute),
                    value: minute,
                  );
                }).toList(),
                onChanged: (newValue) {
                  _minuteSelectChange(context, newValue, minuteSelectFieldName);
                }
            ),
        )
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    final double spaceBetween = 50;

    return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('assigned_orders.activity.label_start_work'.tr()),
                  _createHourMinRow(
                      context, activity.workStartHourController,
                      activity.workStartMin, "workStartMin",
                      hourValidationError: 'assigned_orders.activity.validator_start_work_hour'.tr()
                  ),
                ],
              ),
              Column(
                children: [
                  Text('assigned_orders.activity.label_end_work'.tr()),
                  _createHourMinRow(
                      context, activity.workEndHourController,
                      activity.workEndMin, "workEndMin",
                      hourValidationError: 'assigned_orders.activity.validator_end_work_hour'.tr()
                  ),
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
                  _createHourMinRow(
                      context, activity.travelToHourController,
                      activity.travelToMin, "travelToMin",
                      hourValidationError: 'assigned_orders.activity.validator_travel_to_hours'.tr()
                  ),
                ],
              ),
              Column(
                children: [
                  Text('assigned_orders.activity.label_travel_back'.tr()),
                  _createHourMinRow(
                      context, activity.travelBackHourController,
                      activity.travelBackMin, "travelBackMin",
                      hourValidationError: 'assigned_orders.activity.validator_travel_back_hours'.tr()
                  ),
                ],
              )
            ],
          ),
          SizedBox(
            height: spaceBetween,
          ),
          Row(
            children: [
              Column(
                children: [
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
                ],
              ),
              SizedBox(width: 20),
              Column(
                children: [
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
                  Text('assigned_orders.activity.label_extra_work'.tr()),
                  _createHourMinRow(
                      context, activity.extraWorkHourController,
                      activity.extraWorkMin, "extraWorkMin",
                      hourRequired: false
                  ),
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
          ),
          SizedBox(
            height: spaceBetween,
          ),
          createElevatedButtonColored(
              activity.showActualWork ?
              'assigned_orders.activity.label_actual_work_hide'.tr() :
              'assigned_orders.activity.label_actual_work_show'.tr(),
              () { _toggleShowActualWork(context); }
          ),
          Visibility(
              visible: activity.showActualWork,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text('assigned_orders.activity.label_actual_work'.tr()),
                        _createHourMinRow(
                            context, activity.actualWorkHourController,
                            activity.actualWorkMin, "actualWorkMin",
                            hourRequired: false
                        ),
                      ],
                    )
                  ]
              )
          ),
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
                backgroundColor: Colors.black
            ),
          ),
          SizedBox(
            height: spaceBetween,
          ),
          createDefaultElevatedButton(
              activity.id == null ? 'assigned_orders.activity.button_add_activity'.tr() : 'assigned_orders.activity.button_edit_activity'.tr(),
              () => { _submitForm(context) }
          )
        ],
      );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      // only continue if something is set
      if (!activity.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<ActivityBloc>(context);
      if (activity.id != null) {
        AssignedOrderActivity updatedActivity = activity.toModel();
        bloc.add(ActivityEvent(
            pk: updatedActivity.id,
            status: ActivityEventStatus.UPDATE,
            activity: updatedActivity,
            assignedOrderId: updatedActivity.assignedOrderId
        ));
      } else {
        AssignedOrderActivity newActivity = activity.toModel();
        bloc.add(ActivityEvent(
            status: ActivityEventStatus.INSERT,
            activity: newActivity,
            assignedOrderId: newActivity.assignedOrderId
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<ActivityBloc>(context);
    bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
    bloc.add(ActivityEvent(
        status: ActivityEventStatus.UPDATE_FORM_DATA,
        activityFormData: activity
    ));
  }

}
