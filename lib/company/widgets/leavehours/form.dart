import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/slivers/app_bars.dart';

import 'package:my24app/company/models/leavehours/form_data.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/company/models/leave_type/models.dart';
import 'package:my24app/company/models/leavehours/api.dart';

class UserLeaveHoursFormWidget extends StatefulWidget {
  final UserLeaveHoursFormData? formData;
  final bool isPlanning;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  UserLeaveHoursFormWidget({
    Key? key,
    required this.formData,
    required this.isPlanning,
    required this.widgetsIn,
    required this.i18nIn,
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

  UserLeaveHoursApi api = UserLeaveHoursApi();
  UserLeaveHoursPlanningApi planningApi = UserLeaveHoursPlanningApi();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> minutes = ['00', '05', '10', '15', '20', '25' ,'30', '35', '40', '45', '50', '55'];

  bool isFetchingTotals = false;

  void addListeners() {
    startDateHourTextFocus!.addListener(() {
      if (!startDateHourTextFocus!.hasFocus) {
        if (startDateHourController.text == '') {
          startDateHourController.text = "0";
        }
        print('_updateTotals from startDateMinChange');
        _updateTotals();
      } else {
        print('_updateFormDataGetTotals from startDateMinChange NO FOCUS');
      }
    });

    startDateMinTextFocus!.addListener(() {
      if (!startDateMinTextFocus!.hasFocus) {
        if (startDateMinuteController.text == '') {
          startDateMinuteController.text = "0";
        }
        print('_updateTotals from startDateMinChange');
        _updateTotals();
      } else {
        print('_updateFormDataGetTotals from startDateMinChange NO FOCUS');
      }
    });

    endDateMinTextFocus!.addListener(() {
      if (!endDateMinTextFocus!.hasFocus) {
        if (endDateMinuteController.text == '') {
          endDateMinuteController.text = "0";
        }
        print('_updateTotals from endDateMinChange');
        _updateTotals();
      }
    });

    endDateHourTextFocus!.addListener(() {
      if (!endDateHourTextFocus!.hasFocus) {
        if (endDateHourController.text == '') {
          endDateHourController.text = "0";
        }
        print('_updateTotals from endDateHourChange');
        _updateTotals();
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
    return Scaffold(
        body: CustomScrollView(
            slivers: <Widget>[
              getAppBar(context),
              SliverToBoxAdapter(child: getContent(context))
            ]
        )
    );
  }

  _updateTotals() async {
    setState(() {
      isFetchingTotals = true;
    });
    UserLeaveHours hours = widget.formData!.toModel();
    LeaveHoursData totals = widget.isPlanning ? await planningApi.getTotals(hours) : await api.getTotals(hours);
    totalHourController.text = "${totals.totalHours}";
    totalMinuteController.text = totals.totalMinutes! < 10 ? "0${totals.totalMinutes}" : "${totals.totalMinutes}";
    setState(() {
      isFetchingTotals = false;
    });
  }

  String getAppBarTitle(BuildContext context) {
    return widget.formData!.id == null ? widget.i18nIn.$trans('app_bar_title_new') : widget.i18nIn.$trans('app_bar_title_edit');
  }

  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  SliverAppBar getAppBar(BuildContext context) {
    SmallAppBarFactory factory = SmallAppBarFactory(context: context, title: getAppBarTitle(context));
    return factory.createAppBar();
  }

  Widget getContent(BuildContext context) {
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
                  widget.widgetsIn.createSubmitSection(_getButtons(context) as Row)
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
          widget.widgetsIn.createCancelButton(() => _navList(context)),
          SizedBox(width: 10),
          widget.widgetsIn.createSubmitButton(context, () => _submitForm(context)),
        ]
    );
  }

  Widget _buildForm(BuildContext context) {
    final double spaceBetween = 20;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widget.widgetsIn.wrapGestureDetector(context, Text(widget.i18nIn.$trans('info_leave_type'))),
        DropdownButtonFormField<int>(
          value: widget.formData!.leaveType,
          focusNode: leaveTypeFocus,
          items: widget.formData!.leaveTypes == null || widget.formData!.leaveTypes!.results!.length == 0
              ? []
              : widget.formData!.leaveTypes!.results!.map((LeaveType leaveType) {
            return new DropdownMenuItem<int>(
              child: new Text(leaveType.name!),
              value: leaveType.id,
            );
          }).toList(),
          onTap: () {
            FocusManager.instance.primaryFocus!.unfocus();
          },
          onChanged: (newValue) {
            LeaveType leaveType = widget.formData!.leaveTypes!.results!.firstWhere(
                    (_leaveType) => _leaveType.id == newValue);

            widget.formData!.leaveTypeName = leaveType.name;
            widget.formData!.leaveType = leaveType.id;
            _updateFormData(context);
          },
        ),
        widget.widgetsIn.wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                widget.widgetsIn.wrapGestureDetector(context, widget.widgetsIn.createHeader(widget.i18nIn.$trans('info_start_date'))),
                _buildStartDatePart(context),
              ],
            ),
            Column(
              children: [
                widget.widgetsIn.wrapGestureDetector(context, widget.widgetsIn.createHeader(widget.i18nIn.$trans('info_end_date'))),
                _buildEndDatePart(context),
              ],
            )
          ],
        ),

        _buildHourMinutePart(context),
        widget.widgetsIn.wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),

        widget.widgetsIn.wrapGestureDetector(context, widget.widgetsIn.createHeader(widget.i18nIn.$trans('info_total'))),
        _buildTotalPart(context),
        widget.widgetsIn.wrapGestureDetector(context, SizedBox(
          height: spaceBetween,
        )),
        widget.widgetsIn.wrapGestureDetector(context, Text(widget.i18nIn.$trans('info_description', pathOverride: 'generic'))),
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
    if (widget.formData!.startDate!.isAtSameMomentAs(widget.formData!.endDate!)) {
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
        widget.widgetsIn.createElevatedButtonColored(
            coreUtils.formatDateDDMMYYYY(widget.formData!.startDate!),
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
                title: widget.widgetsIn.wrapGestureDetector(context, Text(widget.i18nIn.$trans('info_whole_day'))),
                value: widget.formData!.startDateIsWholeDay,
                onChanged: (newValue) {
                  widget.formData!.startDateIsWholeDay = newValue;
                  _updateFormData(context);
                }
            )
        ),
        Visibility(
            visible: !widget.formData!.startDateIsWholeDay!,
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
                          labelText: widget.i18nIn.$trans('info_hours')
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
                          labelText: widget.i18nIn.$trans('info_minutes')
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
        widget.widgetsIn.createElevatedButtonColored(
            coreUtils.formatDateDDMMYYYY(widget.formData!.endDate!),
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
                title: widget.widgetsIn.wrapGestureDetector(context, Text(widget.i18nIn.$trans('info_whole_day'))),
                value: widget.formData!.endDateIsWholeDay,
                onChanged: (newValue) {
                  widget.formData!.endDateIsWholeDay = newValue;
                  _updateFormData(context);
                }
            )
        ),
        Visibility(
            visible: !widget.formData!.endDateIsWholeDay!,
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
                          labelText: widget.i18nIn.$trans('info_hours')
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
                          labelText: widget.i18nIn.$trans('info_minutes')
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
      return Text(widget.i18nIn.$trans('fetching_total'));
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
        isPlanning: widget.isPlanning
    ));
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();

      if (!widget.formData!.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);
      if (widget.formData!.id != null) {
        UserLeaveHours updatedUserLeaveHours = widget.formData!.toModel();
        bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
        bloc.add(UserLeaveHoursEvent(
            pk: updatedUserLeaveHours.id,
            status: UserLeaveHoursEventStatus.UPDATE,
            leaveHours: updatedUserLeaveHours,
            isPlanning: widget.isPlanning
        ));
      } else {
        UserLeaveHours newUserLeaveHours = widget.formData!.toModel();
        bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
        bloc.add(UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.INSERT,
            leaveHours: newUserLeaveHours,
            isPlanning: widget.isPlanning
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);
    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.UPDATE_FORM_DATA,
        formData: widget.formData,
        isPlanning: widget.isPlanning
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
      widget.formData!.startDate = pickedDate;
      _updateTotals();
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
      widget.formData!.endDate = pickedDate;
      _updateTotals();
    }
  }

}
