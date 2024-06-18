import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/utils.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/mobile/models/activity/form_data.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/models/activity/models.dart';
import 'package:my24app/mobile/pages/activity.dart';

import '../../../company/models/engineer/models.dart';

class ActivityFormWidget extends BaseSliverPlainStatelessWidget{
  final int? assignedOrderId;
  final AssignedOrderActivityFormData? formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> minutes = ['00', '05', '10', '15', '20', '25' ,'30', '35', '40', '45', '50', '55'];
  final String? memberPicture;
  final bool? newFromEmpty;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  final EngineersForSelect? engineersForSelect;

  ActivityFormWidget({
    Key? key,
    required this.memberPicture,
    required this.assignedOrderId,
    required this.formData,
    required this.newFromEmpty,
    required this.widgetsIn,
    required this.i18nIn,
    required this.engineersForSelect
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: i18nIn
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return formData!.id == null ? i18nIn.$trans('app_bar_title_new') : i18nIn.$trans('app_bar_title_edit');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(
              color: Colors.grey.shade300,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(5),
            )
        ),
        padding: const EdgeInsets.all(14),
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
                  widgetsIn.createSubmitSection(_getButtons(context) as Row)
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
          widgetsIn.createCancelButton(() => _navList(context)),
          SizedBox(width: 10),
          widgetsIn.createSubmitButton(context, () => _submitForm(context)),
        ]
    );
  }

  _selectActivityDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(now.year - 1),
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

  void _selectUser(BuildContext context, int userId) {
    formData!.user = userId;
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: leftWidth,
          child: TextFormField(
            controller: hourController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty && hourRequired) {
                return i18nIn.$trans('validator_required', pathOverride: 'generic');
              }
              return null;
            },
            decoration: new InputDecoration(
              labelText: i18nIn.$trans('info_hours', pathOverride: 'generic'),
              filled: true,
              fillColor: Colors.white,
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

  List<Widget> _createUserDropDownColumnItems(BuildContext context, double spaceBetween) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_user'))),
          DropdownButton<int>(
            key: Key('activity_user_select'),
              value: formData!.user,
              items: engineersForSelect!.engineers!.map((EngineerForSelect engineerForSelect) {
                return new DropdownMenuItem<int>(
                  child: new Text(engineerForSelect.fullNane!),
                  value: engineerForSelect.user_id,
                );
              }).toList(),
              onChanged: (newValue) {
                _selectUser(context, newValue!);
              }
          )
        ],
      ),
      widgetsIn.wrapGestureDetector(context, SizedBox(
        height: spaceBetween,
      )),
    ];
  }

  Widget _buildForm(BuildContext context) {
    final double spaceBetween = 50;

    return Column(
        children: <Widget>[
          if (engineersForSelect != null)
            ..._createUserDropDownColumnItems(context, spaceBetween),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_start_work'))),
                  _createHourMinRow(
                      context, formData!.workStartHourController,
                      formData!.workStartMin, "workStartMin"
                  ),
                ],
              ),
              Column(
                children: [
                  widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_end_work'))),
                  _createHourMinRow(
                      context, formData!.workEndHourController,
                      formData!.workEndMin, "workEndMin"
                  ),
                ],
              )
            ],
          ),
          widgetsIn.wrapGestureDetector(context, SizedBox(
            height: spaceBetween,
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_travel_to'))),
                  SizedBox(height: 8),
                  _createHourMinRow(
                      context, formData!.travelToHourController,
                      formData!.travelToMin, "travelToMin"
                  ),
                ],
              ),
              Column(
                children: [
                  widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_travel_back'))),
                  SizedBox(height: 8),
                  _createHourMinRow(
                      context, formData!.travelBackHourController,
                      formData!.travelBackMin, "travelBackMin"
                  ),
                ],
              )
            ],
          ),
          widgetsIn.wrapGestureDetector(context, SizedBox(
            height: spaceBetween,
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_distance_to'))),
                  SizedBox(height: 8),
                  Container(
                    width: 120,
                    child: TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        controller: formData!.distanceToController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return i18nIn.$trans('validator_required', pathOverride: 'generic');
                          }
                          return null;
                        }),
                  ),
                ],
              ),
              widgetsIn.wrapGestureDetector(context, SizedBox(
                width: 20,
              )),
              Column(
                children: [
                  widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_distance_back'))),
                  SizedBox(height: 8),
                  Container(
                    width: 120,
                    child: TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        controller: formData!.distanceBackController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return i18nIn.$trans('validator_required', pathOverride: 'generic');
                          }
                          return null;
                        }),
                  ),
                ],
              )
            ],
          ),
          widgetsIn.wrapGestureDetector(context, SizedBox(
            height: spaceBetween,
          )),
          widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_extra_work'))),
          SizedBox(height: 8),
          Column(
            children: [
              _createHourMinRow(
                  context, formData!.extraWorkHourController,
                  formData!.extraWorkMin, "extraWorkMin",
                  hourRequired: false
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: formData!.extraWorkDescriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  return null;
                },
                decoration: new InputDecoration(
                  labelText: i18nIn.$trans('info_description'),
                  filled: true,
                  fillColor: Colors.white,
                )
              ),
            ]
          ),
          widgetsIn.wrapGestureDetector(context, SizedBox(
            height: spaceBetween,
          )),
          widgetsIn.createElevatedButtonColored(
              formData!.showActualWork! ? i18nIn.$trans('label_actual_work_hide') : i18nIn.$trans('label_actual_work_show'),
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
                        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_actual_work'))),
                        SizedBox(height: 8),
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
          widgetsIn.wrapGestureDetector(context, SizedBox(
            height: spaceBetween,
          )),
          widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_activity_date'))),
          Container(
            width: 150,
            child: widgetsIn.createElevatedButtonColored(
                coreUtils.formatDateDDMMYYYY(formData!.activityDate!),
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
        activityFormData: formData,
        engineersForSelect: engineersForSelect
    ));
  }
}
