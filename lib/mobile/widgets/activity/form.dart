import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/activity/form_data.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/models/activity/models.dart';
import 'package:my24app/mobile/pages/activity.dart';
import 'package:my24app/core/i18n_mixin.dart';


class ActivityFormWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "assigned_orders.activity";
  final int? assignedOrderId;
  final AssignedOrderActivityFormData? formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> minutes = ['00', '05', '10', '15', '20', '25' ,'30', '35', '40', '45', '50', '55'];
  final String? memberPicture;
  final bool? newFromEmpty;

  ActivityFormWidget({
    Key? key,
    required this.memberPicture,
    required this.assignedOrderId,
    required this.formData,
    required this.newFromEmpty,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return formData!.id == null ? $trans('app_bar_title_new') : $trans('app_bar_title_edit');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
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
                  createSubmitSection(_getButtons(context) as Row)
                ]
              )
            )
          )
        )
    );
  }

  // private methods
  Widget _getButtons(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createCancelButton(() => _navList(context)),
          SizedBox(width: 10),
          createSubmitButton(() => _submitForm(context)),
        ]
    );
  }

  _selectActivityDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(now.year + 2)
    );

    if (pickedDate != null) {
      formData!.activityDate = pickedDate;
      _updateFormData(context);
    }
  }

  void _toggleShowActualWork(BuildContext context) {
    formData!.showActualWork = !formData!.showActualWork!;
    _updateFormData(context);
  }

  void _minuteSelectChange(BuildContext context, String? newValue, String fieldName) {
    switch (fieldName) {
      case "workStartMin": {
        formData!.workStartMin = newValue;
        _updateFormData(context);
      }
      break;

      case "workEndMin": {
        formData!.workEndMin = newValue;
        _updateFormData(context);
      }
      break;

      case "travelToMin": {
        formData!.travelToMin = newValue;
        _updateFormData(context);
      }
      break;

      case "travelBackMin": {
        formData!.travelBackMin = newValue;
        _updateFormData(context);
      }
      break;

      case "extraWorkMin": {
        formData!.extraWorkMin = newValue;
        _updateFormData(context);
      }
      break;

      case "actualWorkMin": {
        formData!.actualWorkMin = newValue;
        _updateFormData(context);
      }
      break;

      default: {
        throw Exception("unknown field: $fieldName");
      }
    }
  }

  Widget _createHourMinRow(
      BuildContext context, TextEditingController? hourController,
      String? minuteSelectValue, String minuteSelectFieldName,
      {
        double leftWidth = 100, double rightWidth = 60, bool
        hourRequired = true
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
              if (value!.isEmpty && hourRequired) {
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
                  wrapGestureDetector(context, Text($trans('label_start_work'))),
                  _createHourMinRow(
                      context, formData!.workStartHourController,
                      formData!.workStartMin, "workStartMin"
                  ),
                ],
              ),
              Column(
                children: [
                  wrapGestureDetector(context, Text($trans('label_end_work'))),
                  _createHourMinRow(
                      context, formData!.workEndHourController,
                      formData!.workEndMin, "workEndMin"
                  ),
                ],
              )
            ],
          ),
          wrapGestureDetector(context, SizedBox(
            height: spaceBetween,
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  wrapGestureDetector(context, Text($trans('label_travel_to'))),
                  _createHourMinRow(
                      context, formData!.travelToHourController,
                      formData!.travelToMin, "travelToMin"
                  ),
                ],
              ),
              Column(
                children: [
                  wrapGestureDetector(context, Text($trans('label_travel_back'))),
                  _createHourMinRow(
                      context, formData!.travelBackHourController,
                      formData!.travelBackMin, "travelBackMin"
                  ),
                ],
              )
            ],
          ),
          wrapGestureDetector(context, SizedBox(
            height: spaceBetween,
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  wrapGestureDetector(context, Text($trans('label_distance_to'))),
                  Container(
                    width: 120,
                    child: TextFormField(
                        controller: formData!.distanceToController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return $trans('validator_required', pathOverride: 'generic');
                          }
                          return null;
                        }),
                  ),
                ],
              ),
              wrapGestureDetector(context, SizedBox(
                width: 20,
              )),
              Column(
                children: [
                  wrapGestureDetector(context, Text($trans('label_distance_back'))),
                  Container(
                    width: 120,
                    child: TextFormField(
                        controller: formData!.distanceBackController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return $trans('validator_required', pathOverride: 'generic');
                          }
                          return null;
                        }),
                  ),
                ],
              )
            ],
          ),
          wrapGestureDetector(context, SizedBox(
            height: spaceBetween,
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  wrapGestureDetector(context, Text($trans('label_extra_work'))),
                  _createHourMinRow(
                      context, formData!.extraWorkHourController,
                      formData!.extraWorkMin, "extraWorkMin",
                      hourRequired: false
                  ),
                ],
              ),
              Container(
                width: 120,
                child: TextFormField(
                    controller: formData!.extraWorkDescriptionController,
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
          wrapGestureDetector(context, SizedBox(
            height: spaceBetween,
          )),
          createElevatedButtonColored(
              formData!.showActualWork! ? $trans('label_actual_work_hide') : $trans('label_actual_work_show'),
              () { _toggleShowActualWork(context); }
          ),
          Visibility(
              visible: formData!.showActualWork!,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        wrapGestureDetector(context, Text($trans('label_actual_work'))),
                        _createHourMinRow(
                            context, formData!.actualWorkHourController,
                            formData!.actualWorkMin, "actualWorkMin",
                            hourRequired: false
                        ),
                      ],
                    )
                  ]
              )
          ),
          wrapGestureDetector(context, SizedBox(
            height: spaceBetween,
          )),
          wrapGestureDetector(context, Text($trans('label_activity_date'))),
          Container(
            width: 150,
            child: createElevatedButtonColored(
                "${formData!.activityDate!.toLocal()}".split(' ')[0],
                () => _selectActivityDate(context),
                foregroundColor: Colors.white,
                backgroundColor: Colors.black
            ),
          ),
        ],
      );
  }

  void _navList(BuildContext context) {
    final page = AssignedOrderActivityPage(
      assignedOrderId: assignedOrderId,
        bloc: ActivityBloc()
    );

    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();

      if (!formData!.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<ActivityBloc>(context);
      if (formData!.id != null) {
        AssignedOrderActivity updatedActivity = formData!.toModel();
        bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
        bloc.add(ActivityEvent(
            pk: updatedActivity.id,
            status: ActivityEventStatus.UPDATE,
            activity: updatedActivity,
            assignedOrderId: updatedActivity.assignedOrderId
        ));
      } else {
        AssignedOrderActivity newActivity = formData!.toModel();
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
        activityFormData: formData
    ));
  }
}
