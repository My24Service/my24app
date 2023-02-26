import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/activity/form_data.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/models/activity/models.dart';
import 'package:my24app/mobile/pages/activity.dart';
import 'package:my24app/core/i18n_mixin.dart';


class ActivityFormWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "assigned_orders.activity";
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
  void doRefresh(BuildContext context) {
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return activity.id == null ? $trans('app_bar_title_new') : $trans('app_bar_title_edit');
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

  // private methods
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
        hourRequired: true
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
                return $trans('validator_required', pathOverride: 'generic');
              }
              return null;
            },
            decoration: new InputDecoration(
              labelText: $trans('info_hours', pathOverride: 'generic')
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
                  Text($trans('label_start_work')),
                  _createHourMinRow(
                      context, activity.workStartHourController,
                      activity.workStartMin, "workStartMin"
                  ),
                ],
              ),
              Column(
                children: [
                  Text($trans('label_end_work')),
                  _createHourMinRow(
                      context, activity.workEndHourController,
                      activity.workEndMin, "workEndMin"
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
                  Text($trans('label_travel_to')),
                  _createHourMinRow(
                      context, activity.travelToHourController,
                      activity.travelToMin, "travelToMin"
                  ),
                ],
              ),
              Column(
                children: [
                  Text($trans('label_travel_back')),
                  _createHourMinRow(
                      context, activity.travelBackHourController,
                      activity.travelBackMin, "travelBackMin"
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
                  Text($trans('label_distance_to')),
                  Container(
                    width: 120,
                    child: TextFormField(
                        controller: activity.distanceToController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return $trans('validator_required', pathOverride: 'generic');
                          }
                          return null;
                        }),
                  ),
                ],
              ),
              SizedBox(width: 20),
              Column(
                children: [
                  Text($trans('label_distance_back')),
                  Container(
                    width: 120,
                    child: TextFormField(
                        controller: activity.distanceBackController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return $trans('validator_required', pathOverride: 'generic');
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
                  Text($trans('label_extra_work')),
                  _createHourMinRow(
                      context, activity.extraWorkHourController,
                      activity.extraWorkMin, "extraWorkMin",
                      hourRequired: false
                  ),
                ],
              ),
              Container(
                width: 120,
                child: TextFormField(
                    controller: activity.extraWorkDescriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    validator: (value) {
                      return null;
                    },
                    decoration: new InputDecoration(
                        labelText: $trans('info_description')
                    )
                ),
              )
            ],
          ),
          SizedBox(
            height: spaceBetween,
          ),
          createElevatedButtonColored(
              activity.showActualWork ? $trans('label_actual_work_hide') : $trans('label_actual_work_show'),
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
                        Text($trans('label_actual_work')),
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
          Text($trans('label_activity_date')),
          Container(
            width: 150,
            child: createElevatedButtonColored(
                "${activity.activityDate.toLocal()}".split(' ')[0],
                () => _selectActivityDate(context),
                foregroundColor: Colors.white,
                backgroundColor: Colors.black
            ),
          ),
        ],
      );
  }

  void _navList(BuildContext context) {
    final page = AssignedOrderActivityPage(assignedOrderId: assignedOrderId);
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      if (!activity.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<ActivityBloc>(context);
      if (activity.id != null) {
        AssignedOrderActivity updatedActivity = activity.toModel();
        bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
        bloc.add(ActivityEvent(
            pk: updatedActivity.id,
            status: ActivityEventStatus.UPDATE,
            activity: updatedActivity,
            assignedOrderId: updatedActivity.assignedOrderId
        ));
      } else {
        AssignedOrderActivity newActivity = activity.toModel();
        bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
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

  @override
  Widget getBottomSection(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createElevatedButtonColored(
            $trans('action_cancel', pathOverride: 'generic'),
            () => { _navList(context) }
          ),
          SizedBox(width: 10),
          createDefaultElevatedButton(
            activity.id == null ? $trans('button_add') : $trans('button_edit'),
            () => { _submitForm(context) }
          ),
      ]
    );
  }

}