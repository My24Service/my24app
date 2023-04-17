import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/company/models/leavehours/form_data.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/company/models/leave_type/models.dart';

class UserLeaveHoursFormWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "company.leavehours";
  final UserLeaveHoursFormData formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> minutes = ['00', '05', '10', '15', '20', '25' ,'30', '35', '40', '45', '50', '55'];
  final String memberPicture;
  final bool isPlanning;

  UserLeaveHoursFormWidget({
    Key key,
    @required this.memberPicture,
    @required this.formData,
    @required this.isPlanning,
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
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createElevatedButtonColored(
              $trans('action_cancel', pathOverride: 'generic'),
              () => { _navList(context) }
          ),
          SizedBox(width: 10),
          createDefaultElevatedButton(
              formData.id == null ? $trans('button_add') : $trans('button_edit'),
              () => { _submitForm(context) }
          ),
        ]
    );
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
                ]
              )
            )
          )
        )
    );
  }

  // private methods
  _selectStartDate(BuildContext context) async {
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
        Text($trans('info_leave_type')),
        DropdownButtonFormField<int>(
          value: formData.leaveType,
          items: formData.leaveTypes == null || formData.leaveTypes.results.length == 0
              ? []
              : formData.leaveTypes.results.map((LeaveType leaveType) {
            return new DropdownMenuItem<int>(
              child: new Text(leaveType.name),
              value: leaveType.id,
            );
          }).toList(),
          onChanged: (newValue) {
            LeaveType leaveType = formData.leaveTypes.results.firstWhere(
                    (_leaveType) => _leaveType.id == newValue);
            formData.leaveTypeName = leaveType.name;
            formData.leaveType = leaveType.id;
            _updateFormData(context);
          },
        ),
        SizedBox(
          height: spaceBetween,
        ),
        Text($trans('info_description', pathOverride: 'generic')),
        TextFormField(
            controller: formData.descriptionController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: spaceBetween,
        ),
        Text($trans('info_start_date')),
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
                Text($trans('label_start_date_hours')),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                        controller: formData.startDateHourController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return $trans('validator_start_date_hours');
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
                        child: _buildStartDateMinutes(context)
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
        Text($trans('label_description')),
        Container(
          width: 150,
          child: TextFormField(
              controller: formData.descriptionController,
              validator: (value) {
                return null;
              }),
        ), // extra work
      ],
    );
  }

  _buildStartDateMinutes(BuildContext context) {
    return DropdownButton<String>(
      value: formData.startDateMinutes,
      items: minutes.map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        formData.startDateMinutes = newValue;
        _updateFormData(context);
      },
    );
  }

  void _navList(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);
    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.FETCH_ALL,
        isPlanning: isPlanning
    ));
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      if (!formData.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);
      if (formData.id != null) {
        UserLeaveHours updatedUserLeaveHours = formData.toModel();
        bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
        bloc.add(UserLeaveHoursEvent(
            pk: updatedUserLeaveHours.id,
            status: UserLeaveHoursEventStatus.UPDATE,
            leaveHours: updatedUserLeaveHours,
            isPlanning: isPlanning
        ));
      } else {
        UserLeaveHours newUserLeaveHours = formData.toModel();
        bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
        bloc.add(UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.INSERT,
            leaveHours: newUserLeaveHours,
            isPlanning: isPlanning
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);
    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.UPDATE_FORM_DATA,
        formData: formData,
        isPlanning: isPlanning
    ));
  }
}
