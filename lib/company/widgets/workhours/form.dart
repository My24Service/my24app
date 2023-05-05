import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/company/models/workhours/form_data.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'package:my24app/company/models/workhours/models.dart';
import 'package:my24app/company/models/project/models.dart';

class UserWorkHoursFormWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "company.workhours";
  final UserWorkHoursFormData formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> minutes = ['00', '05', '10', '15', '20', '25' ,'30', '35', '40', '45', '50', '55'];
  final String memberPicture;

  UserWorkHoursFormWidget({
    Key key,
    @required this.memberPicture,
    @required this.formData
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  @override
  void doRefresh(BuildContext context) {
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return formData.id == null ? $trans('app_bar_title_new') : $trans('app_bar_title_edit');
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
                  createSubmitSection(_getButtons(context))
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

  _selectStartDate(BuildContext context) async {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        // theme: DatePickerTheme(
        //     headerColor: Colors.orange,
        //     backgroundColor: Colors.blue,
        //     itemStyle: TextStyle(
        //         color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        //     doneStyle: TextStyle(color: Colors.white, fontSize: 16)
        // ),
        onChanged: (date) {
        },
        onConfirm: (date) {
          formData.startDate = date;
          _updateFormData(context);
        },
        currentTime: formData.startDate,
        locale: LocaleType.en
    );
  }

  Widget _buildForm(BuildContext context) {
    final double leftWidth = 100;
    final double rightWidth = 60;
    final double spaceBetween = 50;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        wrapGestureDetector(context, Text($trans('info_project'))),
        DropdownButtonFormField<String>(
          value: formData.projectName,
          items: formData.projects == null || formData.projects.results.length == 0
              ? []
              : formData.projects.results.map((Project project) {
            return new DropdownMenuItem<String>(
              child: new Text(project.name),
              value: project.name,
            );
          }).toList(),
          onChanged: (newValue) {
            Project project = formData.projects.results.firstWhere(
                    (_proj) => _proj.name == newValue);
            formData.projectName = newValue;
            formData.project = project.id;
            _updateFormData(context);
          },
        ),
        wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        wrapGestureDetector(context, Text($trans('info_description', pathOverride: 'generic'))),
        TextFormField(
            controller: formData.descriptionController,
            validator: (value) {
              return null;
            }),
        wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        wrapGestureDetector(context, Text($trans('info_start_date'))),
        createElevatedButtonColored(
            "${formData.startDate.toLocal()}".split(' ')[0],
            () => _selectStartDate(context),
            foregroundColor: Colors.white,
            backgroundColor: Colors.black
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                wrapGestureDetector(context, Text($trans('label_start_work', pathOverride: 'assigned_orders.activity'))),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                        controller: formData.workStartHourController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return $trans('validator_start_work_hour', pathOverride: 'assigned_orders.activity');
                          }
                          return null;
                        },
                        decoration: new InputDecoration(
                            labelText: $trans('info_hours')
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
        wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                wrapGestureDetector(context, Text($trans('label_end_work', pathOverride: 'assigned_orders.activity'))),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          controller: formData.workEndHourController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.isEmpty) {
                              return $trans('validator_end_work_hour', pathOverride: 'assigned_orders.activity');
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                              labelText: $trans('info_hours')
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
        wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                wrapGestureDetector(context, Text($trans('label_travel_to', pathOverride: 'assigned_orders.activity'))),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          controller: formData.travelToHourController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return null;
                          },
                          decoration: new InputDecoration(
                              labelText: $trans('info_hours')
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
        wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                wrapGestureDetector(context, Text($trans('label_travel_back', pathOverride: 'assigned_orders.activity'))),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          controller: formData.travelBackHourController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return null;
                          },
                          decoration: new InputDecoration(
                              labelText: $trans('info_hours')
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
        wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        wrapGestureDetector(context, Text($trans('label_distance_to', pathOverride: 'assigned_orders.activity'))),
        Container(
          width: 150,
          child: TextFormField(
              controller: formData.distanceToController,
              keyboardType: TextInputType.number,
              validator: (value) {
                return null;
              }),
        ),

        wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        wrapGestureDetector(context, Text($trans('label_distance_back', pathOverride: 'assigned_orders.activity'))),
        Container(
          width: 150,
          child: TextFormField(
              controller: formData.distanceBackController,
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
      value: formData.workStartMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        formData.workStartMin = newValue;
        _updateFormData(context);
      },
    );
  }

  _buildWorkEndMinutes(BuildContext context) {
    return DropdownButton<String>(
      value: formData.workEndMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        formData.workEndMin = newValue;
        _updateFormData(context);
      },
    );
  }

  _buildTravelToMinutes(BuildContext context) {
    return DropdownButton<String>(
      value: formData.travelToMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        formData.travelToMin = newValue;
        _updateFormData(context);
      },
    );
  }

  _buildTravelBackMinutes(BuildContext context) {
    return DropdownButton<String>(
      value: formData.travelBackMin,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        formData.travelBackMin = newValue;
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
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      if (!formData.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<UserWorkHoursBloc>(context);
      if (formData.id != null) {
        UserWorkHours updatedUserWorkHours = formData.toModel();
        bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
        bloc.add(UserWorkHoursEvent(
            pk: updatedUserWorkHours.id,
            status: UserWorkHoursEventStatus.UPDATE,
            workHours: updatedUserWorkHours,
        ));
      } else {
        UserWorkHours newUserWorkHours = formData.toModel();
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
