import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/company/models/leavehours/form_data.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/company/models/leave_type/models.dart';

_updateFormDataGetTotals(UserLeaveHoursFormData formData, bool isPlanning) {
  final bloc = UserLeaveHoursBloc();

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

class UserLeaveHoursFormWidget extends StatefulWidget {
  final String? memberPicture;
  final UserLeaveHoursFormData? formData;
  final bool isPlanning;
  final bool? isFetchingTotals;

  UserLeaveHoursFormWidget({
    Key? key,
    required this.memberPicture,
    required this.formData,
    required this.isPlanning,
    required this.isFetchingTotals,
  });

  @override
  State<StatefulWidget> createState() => new _UserLeaveHoursFormWidgetState();
}

class _UserLeaveHoursFormWidgetState extends State<UserLeaveHoursFormWidget> with TextEditingControllerMixin {
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController startDateHourController = TextEditingController();
  final TextEditingController startDateMinuteController = TextEditingController();

  final TextEditingController endDateHourController = TextEditingController();
  final TextEditingController endDateMinuteController = TextEditingController();

  final TextEditingController totalHourController = TextEditingController();
  final TextEditingController totalMinuteController = TextEditingController();

  FocusNode? startDateMinTextFocus;
  FocusNode? startDateHourTextFocus;
  FocusNode? endDateMinTextFocus;
  FocusNode? endDateHourTextFocus;
  FocusNode? leaveTypeFocus;

  void addListeners() {
    startDateHourTextFocus!.addListener(() {
      if (!startDateHourTextFocus!.hasFocus) {
        if (startDateHourController.text == '') {
          startDateHourController.text = "0";
        }
        print('_updateFormDataGetTotals from startDateMinChange');
        _updateFormDataGetTotals(widget.formData!, widget.isPlanning);
      } else {
        print('_updateFormDataGetTotals from startDateMinChange NO FOCUS');
      }
    });

    startDateMinTextFocus!.addListener(() {
      if (!startDateMinTextFocus!.hasFocus) {
        if (startDateMinuteController.text == '') {
          startDateMinuteController.text = "0";
        }
        print('_updateFormDataGetTotals from startDateMinChange');
        _updateFormDataGetTotals(widget.formData!, widget.isPlanning);
      } else {
        print('_updateFormDataGetTotals from startDateMinChange NO FOCUS');
      }
    });

    endDateMinTextFocus!.addListener(() {
      if (!endDateMinTextFocus!.hasFocus) {
        if (endDateMinuteController.text == '') {
          endDateMinuteController.text = "0";
        }
        print('_updateFormDataGetTotals from endDateMinChange');
        _updateFormDataGetTotals(widget.formData!, widget.isPlanning);
      }
    });

    endDateHourTextFocus!.addListener(() {
      if (!endDateHourTextFocus!.hasFocus) {
        if (endDateHourController.text == '') {
          endDateHourController.text = "0";
        }
        print('_updateFormDataGetTotals from endDateHourChange');
        // await async call
        // update total hours / minutes controllers
        // setstate
        // ofzo
        _updateFormDataGetTotals(widget.formData!, widget.isPlanning);

      }
    });
  }

  @override
  void initState() {
    startDateHourTextFocus = createFocusNode();
    startDateMinTextFocus = createFocusNode();
    endDateMinTextFocus = createFocusNode();
    endDateHourTextFocus = createFocusNode();
    leaveTypeFocus = createFocusNode();

    addListeners();

    addTextEditingController(descriptionController, widget.formData!, 'description');

    addTextEditingController(startDateHourController, widget.formData!, 'startDateHours');
    addTextEditingController(startDateMinuteController, widget.formData!, 'startDateMinutes');

    addTextEditingController(endDateHourController, widget.formData!, 'endDateHours');
    addTextEditingController(endDateMinuteController, widget.formData!, 'endDateMinutes');

    addTextEditingController(totalHourController, widget.formData!, 'totalHours');
    addTextEditingController(totalMinuteController, widget.formData!, 'totalMinutes');

    super.initState();
  }

  void dispose() {
    disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('BUILD');
    return new _UserLeaveHoursFormWidget(
        memberPicture: widget.memberPicture,
        formData: widget.formData,

        startDateMinTextFocus: startDateMinTextFocus!,
        startDateHourTextFocus: startDateHourTextFocus!,
        endDateMinTextFocus: endDateMinTextFocus!,
        endDateHourTextFocus: endDateHourTextFocus!,
        leaveTypeFocus: leaveTypeFocus!,

        descriptionController: descriptionController,
        startDateMinuteController: startDateMinuteController,
        startDateHourController: startDateHourController,
        endDateMinuteController: endDateMinuteController,
        endDateHourController: endDateHourController,
        totalMinuteController: totalMinuteController,
        totalHourController: totalHourController,
        isPlanning: widget.isPlanning,
        isFetchingTotals: widget.isFetchingTotals,
    );
  }
}

class _UserLeaveHoursFormWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "company.leavehours";
  final UserLeaveHoursFormData? formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> minutes = ['00', '05', '10', '15', '20', '25' ,'30', '35', '40', '45', '50', '55'];
  final String? memberPicture;
  final bool isPlanning;
  final FocusNode startDateMinTextFocus;
  final FocusNode startDateHourTextFocus;
  final FocusNode endDateMinTextFocus;
  final FocusNode endDateHourTextFocus;
  final FocusNode leaveTypeFocus;
  final bool? isFetchingTotals;

  final TextEditingController descriptionController;

  final TextEditingController startDateHourController;
  final TextEditingController startDateMinuteController;

  final TextEditingController endDateHourController;
  final TextEditingController endDateMinuteController;

  final TextEditingController totalHourController;
  final TextEditingController totalMinuteController;

  _UserLeaveHoursFormWidget({
    Key? key,
    required this.memberPicture,
    required this.formData,
    required this.isPlanning,
    required this.isFetchingTotals,

    required this.startDateMinTextFocus,
    required this.startDateHourTextFocus,
    required this.endDateMinTextFocus,
    required this.endDateHourTextFocus,
    required this.leaveTypeFocus,

    required this.descriptionController,
    required this.startDateHourController,
    required this.startDateMinuteController,
    required this.endDateHourController,
    required this.endDateMinuteController,
    required this.totalHourController,
    required this.totalMinuteController
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
            child: SingleChildScrollView(
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

  Widget _buildForm(BuildContext context) {
    final double spaceBetween = 20;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        wrapGestureDetector(context, Text($trans('info_leave_type'))),
        DropdownButtonFormField<int>(
          value: formData!.leaveType,
          focusNode: leaveTypeFocus,
          items: formData!.leaveTypes == null || formData!.leaveTypes!.results!.length == 0
              ? []
              : formData!.leaveTypes!.results!.map((LeaveType leaveType) {
            return new DropdownMenuItem<int>(
              child: new Text(leaveType.name!),
              value: leaveType.id,
            );
          }).toList(),
          onTap: () {
            FocusManager.instance.primaryFocus!.unfocus();
          },
          onChanged: (newValue) {
            LeaveType leaveType = formData!.leaveTypes!.results!.firstWhere(
                    (_leaveType) => _leaveType.id == newValue);

            formData!.leaveTypeName = leaveType.name;
            formData!.leaveType = leaveType.id;
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
              controller: descriptionController,
              validator: (value) {
                return null;
              }),
        ), // extra work
      ],
    );
  }

  Widget _buildHourMinutePart(BuildContext context) {
    // when same date, only show "whole day" and total hour/minutes
    if (formData!.startDate!.isAtSameMomentAs(formData!.endDate!)) {
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
            utils.formatDateDDMMYYYY(formData!.startDate!),
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
                value: formData!.startDateIsWholeDay,
                onChanged: (newValue) {
                  formData!.startDateIsWholeDay = newValue;
                  _updateFormData(context);
                }
            )
        ),
        Visibility(
            visible: !formData!.startDateIsWholeDay!,
            child: Container(
              width: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    child: TextFormField(
                      key: UniqueKey(),
                      focusNode: startDateHourTextFocus,
                      controller: startDateHourController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
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
                      key: UniqueKey(),
                      focusNode: startDateMinTextFocus,
                      controller: startDateMinuteController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
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
            utils.formatDateDDMMYYYY(formData!.endDate!),
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
                value: formData!.endDateIsWholeDay,
                onChanged: (newValue) {
                  formData!.endDateIsWholeDay = newValue;
                  _updateFormData(context);
                }
            )
        ),
        Visibility(
            visible: !formData!.endDateIsWholeDay!,
            child: Container(
              width: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    child: TextFormField(
                      focusNode: endDateHourTextFocus,
                      controller: endDateHourController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
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
                      controller: endDateMinuteController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
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
    if (isFetchingTotals!) {
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
                    controller: totalHourController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
                Text(' : '),
                Container(
                  width: 60,
                  child: TextFormField(
                    controller: totalMinuteController,
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
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();

      if (!formData!.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);
      if (formData!.id != null) {
        UserLeaveHours updatedUserLeaveHours = formData!.toModel();
        bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
        bloc.add(UserLeaveHoursEvent(
            pk: updatedUserLeaveHours.id,
            status: UserLeaveHoursEventStatus.UPDATE,
            leaveHours: updatedUserLeaveHours,
            isPlanning: isPlanning
        ));
      } else {
        UserLeaveHours newUserLeaveHours = formData!.toModel();
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
      _updateFormDataGetTotals(formData!, isPlanning);
    }
  }

  _selectEndDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2)
    );

    if (pickedDate != null) {
      formData!.endDate = pickedDate;
      _updateFormDataGetTotals(formData!, isPlanning);
    }
  }

}
