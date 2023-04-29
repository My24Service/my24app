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
  final FocusNode startDateMinTextFocus = new FocusNode();
  final FocusNode startDateHourTextFocus = new FocusNode();
  final FocusNode endDateMinTextFocus = new FocusNode();
  final FocusNode endDateHourTextFocus = new FocusNode();
  final FocusNode leaveTypeFocus = new FocusNode();
  final bool isFetchingTotals;

  UserLeaveHoursFormWidget({
    Key key,
    @required this.memberPicture,
    @required this.formData,
    @required this.isPlanning,
    @required this.isFetchingTotals,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  void startDateMinChange(BuildContext context) {
    if (!startDateMinTextFocus.hasFocus) {
      if (formData.startDateMinuteController.text == null || formData.startDateMinuteController.text == '') {
        formData.startDateMinuteController.text = "0";
      }
      print('_updateFormDataGetTotals from startDateMinChange');
      _updateFormDataGetTotals(context);
    }
  }

  void startDateHourChange(BuildContext context) {
    if (!startDateHourTextFocus.hasFocus) {
      if (formData.startDateHourController.text == null || formData.startDateHourController.text == '') {
        formData.startDateHourController.text = "0";
      }
      print('_updateFormDataGetTotals from startDateHourChange');
      _updateFormDataGetTotals(context);
    }
  }

  void endDateMinChange(BuildContext context) {
    if (!endDateMinTextFocus.hasFocus) {
      if (formData.endDateMinuteController.text == null || formData.endDateMinuteController.text == '') {
        formData.endDateMinuteController.text = "0";
      }
      print('_updateFormDataGetTotals from endDateMinChange');
      _updateFormDataGetTotals(context);
    }
  }

  void endDateHourChange(BuildContext context) {
    if (!endDateHourTextFocus.hasFocus) {
      if (formData.endDateHourController.text == null || formData.endDateHourController.text == '') {
        formData.endDateHourController.text = "0";
      }
      print('_updateFormDataGetTotals from endDateHourChange');
      _updateFormDataGetTotals(context);
    }
  }

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
    startDateMinTextFocus.addListener(() { startDateMinChange(context);} );
    startDateHourTextFocus.addListener(() { startDateHourChange(context); } );
    endDateMinTextFocus.addListener(() { endDateMinChange(context); } );
    endDateHourTextFocus.addListener(() { endDateHourChange(context); } );

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
          createDefaultElevatedButton(
              formData.id == null ? $trans('button_add') : $trans('button_edit'),
                  () => { _submitForm(context) }
          ),
        ]
    );
  }

  Widget _buildForm(BuildContext context) {
    final double spaceBetween = 20;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        wrapGestureDetector(context, Text($trans('info_leave_type'))),
        DropdownButtonFormField<int>(
          value: formData.leaveType,
          focusNode: leaveTypeFocus,
          items: formData.leaveTypes == null || formData.leaveTypes.results.length == 0
              ? []
              : formData.leaveTypes.results.map((LeaveType leaveType) {
            return new DropdownMenuItem<int>(
              child: new Text(leaveType.name),
              value: leaveType.id,
            );
          }).toList(),
          onTap: () {
            FocusManager.instance.primaryFocus.unfocus();
          },
          onChanged: (newValue) {
            LeaveType leaveType = formData.leaveTypes.results.firstWhere(
                    (_leaveType) => _leaveType.id == newValue);

            formData.leaveTypeName = leaveType.name;
            formData.leaveType = leaveType.id;
            _updateFormData(context);
          },
        ),
        wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                wrapGestureDetector(context, createHeader($trans('info_start_date'))),
                _buildStartDatePart(context),
              ],
            ),
            Column(
              children: [
                wrapGestureDetector(context, createHeader($trans('info_end_date'))),
                _buildEndDatePart(context),
              ],
            )
          ],
        ),

        _buildHourMinutePart(context),
        wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),

        wrapGestureDetector(context, createHeader($trans('info_total'))),
        _buildTotalPart(context),
        wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        wrapGestureDetector(context, Text($trans('info_description', pathOverride: 'generic'))),
        Container(
          width: 250,
          child: TextFormField(
              controller: formData.descriptionController,
              validator: (value) {
                return null;
              }),
        ), // extra work
      ],
    );
  }

  Widget _buildHourMinutePart(BuildContext context) {
    // when same date, only show "whole day" and total hour/minutes
    if (formData.startDate.isAtSameMomentAs(formData.endDate)) {
      return _buildStartTimePart(context);
    }

    // different dates, show both "whole day" and hour/minutes
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildStartTimePart(context),
          ],
        ),
        Column(
          children: [
            _buildEndTimePart(context),
          ],
        )
      ],
    );
  }

  Widget _buildStartDatePart(BuildContext context) {
    return Column(
      children: [
        createElevatedButtonColored(
            "${formData.startDate.toLocal()}".split(' ')[0],
            () => _selectStartDate(context),
            foregroundColor: Colors.black,
            backgroundColor: Colors.white
        ),
      ],
    );
  }

  Widget _buildStartTimePart(BuildContext context) {
    return Column(
      children: [
        Container(
            width: 170,
            child: CheckboxListTile(
                title: wrapGestureDetector(context, Text($trans('info_whole_day'))),
                value: formData.startDateIsWholeDay,
                onChanged: (newValue) {
                  formData.startDateIsWholeDay = newValue;
                  _updateFormData(context);
                }
            )
        ),
        Visibility(
            visible: !formData.startDateIsWholeDay,
            child: Container(
              width: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    child: TextFormField(
                      focusNode: startDateHourTextFocus,
                      controller: formData.startDateHourController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty) {
                        }
                        return null;
                      },
                      decoration: new InputDecoration(
                          labelText: $trans('info_hours')
                      ),
                    ),
                  ),
                  Text(' : '),
                  Container(
                    width: 60,
                    child: TextFormField(
                      focusNode: startDateMinTextFocus,
                      controller: formData.startDateMinuteController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty) {
                        }
                        return null;
                      },
                      decoration: new InputDecoration(
                          labelText: $trans('info_minutes')
                      ),
                    ),
                  ),
                ],
              ),
            )
        )
      ],
    );
  }

  Widget _buildEndDatePart(BuildContext context) {
    return Column(
      children: [
        createElevatedButtonColored(
            "${formData.endDate.toLocal()}".split(' ')[0],
            () => _selectEndDate(context),
            foregroundColor: Colors.black,
            backgroundColor: Colors.white
        )
      ],
    );
  }

  Widget _buildEndTimePart(BuildContext context) {
    return Column(
      children: [
        Container(
            width: 170,
            child: CheckboxListTile(
                title: wrapGestureDetector(context, Text($trans('info_whole_day'))),
                value: formData.endDateIsWholeDay,
                onChanged: (newValue) {
                  formData.endDateIsWholeDay = newValue;
                  _updateFormData(context);
                }
            )
        ),
        Visibility(
            visible: !formData.endDateIsWholeDay,
            child: Container(
              width: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    child: TextFormField(
                      focusNode: endDateHourTextFocus,
                      controller: formData.endDateHourController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty) {
                        }
                        return null;
                      },
                      decoration: new InputDecoration(
                          labelText: $trans('info_hours')
                      ),
                    ),
                  ),
                  Text(' : '),
                  Container(
                    width: 60,
                    child: TextFormField(
                      focusNode: endDateMinTextFocus,
                      controller: formData.endDateMinuteController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty) {
                        }
                        return null;
                      },
                      decoration: new InputDecoration(
                          labelText: $trans('info_minutes')
                      ),
                    ),
                  ),
                ],
              ),
            )
        )
      ],
    );
  }

  Widget _buildTotalPart(BuildContext context) {
    if (isFetchingTotals) {
      return Text($trans('fetching_total'));
    }

    return Column(
      children: [
          Container(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  child: TextFormField(
                    controller: formData.totalHourController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
                Text(' : '),
                Container(
                  width: 60,
                  child: TextFormField(
                    controller: formData.totalMinuteController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
              ],
            ),
          )
        ]
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

  _updateFormDataGetTotals(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.DO_GET_TOTALS,
        formData: formData,
        isPlanning: isPlanning
    ));

    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.GET_TOTALS,
        formData: formData,
        isPlanning: isPlanning
    ));
  }

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
          _updateFormDataGetTotals(context);
        },
        currentTime: formData.startDate,
        locale: LocaleType.en
    );
  }

  _selectEndDate(BuildContext context) async {
    DatePicker.showDatePicker(context,
        minTime: formData.startDate,
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
          formData.endDate = date;
          _updateFormDataGetTotals(context);
        },
        currentTime: formData.endDate,
        locale: LocaleType.en
    );
  }

}
