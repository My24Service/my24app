import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/company/models/workhours/form_data.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'package:my24app/company/models/workhours/models.dart';
import 'package:my24app/company/models/project/models.dart';

class UserWorkHoursFormWidget extends BaseSliverPlainStatelessWidget{
  final String basePath = "company.workhours";
  final UserWorkHoursFormData? formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> minutes = ['00', '05', '10', '15', '20', '25' ,'30', '35', '40', '45', '50', '55'];
  final String? memberPicture;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  
  UserWorkHoursFormWidget({
    Key? key,
    required this.memberPicture,
    required this.formData,
    required this.widgetsIn,
    required this.i18nIn,
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
        child: Form(
          key: _formKey,
          child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
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

  _selectStartDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2)
    );

    if (pickedDate != null) {
      formData!.startDate = pickedDate;
      _updateFormData(context);
    }
  }

  Widget _buildForm(BuildContext context) {
    final double leftWidth = 100;
    final double rightWidth = 60;
    final double spaceBetween = 50;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('info_project'))),
        DropdownButtonFormField<String>(
          value: formData!.projectName,
          items: formData!.projects == null || formData!.projects!.results!.length == 0
              ? []
              : formData!.projects!.results!.map((Project project) {
            return new DropdownMenuItem<String>(
              child: new Text(project.name!),
              value: project.name,
            );
          }).toList(),
          onChanged: (newValue) {
            Project project = formData!.projects!.results!.firstWhere(
                    (_proj) => _proj.name == newValue);
            formData!.projectName = newValue;
            formData!.project = project.id;
            _updateFormData(context);
          },
        ),
        widgetsIn.wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('info_description', pathOverride: 'generic'))),
        TextFormField(
            key: UniqueKey(),
            controller: formData!.descriptionController,
            validator: (value) {
              return null;
            }),
        widgetsIn.wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('info_start_date'))),
        widgetsIn.createElevatedButtonColored(
            coreUtils.formatDateDDMMYYYY(formData!.startDate!),
            () => _selectStartDate(context),
            foregroundColor: Colors.white,
            backgroundColor: Colors.black
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_start_work', pathOverride: 'assigned_orders.activity'))),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                        key: UniqueKey(),
                        controller: formData!.workStartHourController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return i18nIn.$trans('validator_start_work_hour', pathOverride: 'assigned_orders.activity');
                          }
                          return null;
                        },
                        decoration: new InputDecoration(
                            labelText: i18nIn.$trans('info_hours')
                        ),
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildWorkStartMinutes(context)
                    )
                  ],
                )
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
                widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_end_work', pathOverride: 'assigned_orders.activity'))),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          key: UniqueKey(),
                          controller: formData!.workEndHourController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return i18nIn.$trans('validator_end_work_hour', pathOverride: 'assigned_orders.activity');
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                              labelText: i18nIn.$trans('info_hours')
                          )
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildWorkEndMinutes(context)
                    )
                  ],
                )
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
                widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_travel_to', pathOverride: 'assigned_orders.activity'))),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          key: UniqueKey(),
                          controller: formData!.travelToHourController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return null;
                          },
                          decoration: new InputDecoration(
                              labelText: i18nIn.$trans('info_hours')
                          )
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildTravelToMinutes(context)
                    )
                  ],
                )
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
                widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_travel_back', pathOverride: 'assigned_orders.activity'))),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          key: UniqueKey(),
                          controller: formData!.travelBackHourController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return null;
                          },
                          decoration: new InputDecoration(
                              labelText: i18nIn.$trans('info_hours')
                          )
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildTravelBackMinutes(context)
                    )
                  ],
                )
              ],
            )
          ],
        ),
        widgetsIn.wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_distance_to', pathOverride: 'assigned_orders.activity'))),
        Container(
          width: 150,
          child: TextFormField(
              key: UniqueKey(),
              controller: formData!.distanceToController,
              keyboardType: TextInputType.number,
              validator: (value) {
                return null;
              }),
        ),

        widgetsIn.wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('label_distance_back', pathOverride: 'assigned_orders.activity'))),
        Container(
          width: 150,
          child: TextFormField(
              key: UniqueKey(),
              controller: formData!.distanceBackController,
              keyboardType: TextInputType.number,
              validator: (value) {
                return null;
              }),
        ),
        // extra work
      ],
    );
  }

  _buildWorkStartMinutes(BuildContext context) {
    return DropdownButton<String>(
      value: formData!.workStartMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        formData!.workStartMin = newValue;
        _updateFormData(context);
      },
    );
  }

  _buildWorkEndMinutes(BuildContext context) {
    return DropdownButton<String>(
      value: formData!.workEndMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        formData!.workEndMin = newValue;
        _updateFormData(context);
      },
    );
  }

  _buildTravelToMinutes(BuildContext context) {
    return DropdownButton<String>(
      value: formData!.travelToMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        formData!.travelToMin = newValue;
        _updateFormData(context);
      },
    );
  }

  _buildTravelBackMinutes(BuildContext context) {
    return DropdownButton<String>(
      value: formData!.travelBackMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        formData!.travelBackMin = newValue;
        _updateFormData(context);
      },
    );
  }

  void _navList(BuildContext context) {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);
    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.FETCH_ALL
    ));
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();

      if (!formData!.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<UserWorkHoursBloc>(context);
      if (formData!.id != null) {
        UserWorkHours updatedUserWorkHours = formData!.toModel();
        bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
        bloc.add(UserWorkHoursEvent(
            pk: updatedUserWorkHours.id,
            status: UserWorkHoursEventStatus.UPDATE,
            workHours: updatedUserWorkHours,
        ));
      } else {
        UserWorkHours newUserWorkHours = formData!.toModel();
        bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
        bloc.add(UserWorkHoursEvent(
            status: UserWorkHoursEventStatus.INSERT,
            workHours: newUserWorkHours,
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);
    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.UPDATE_FORM_DATA,
        formData: formData
    ));
  }
}
